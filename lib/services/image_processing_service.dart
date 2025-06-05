// lib/image_processing_service.dart
import 'dart:async';
import 'dart:convert'; // For base64Encode, jsonEncode
import 'dart:isolate'; // For SendPort, ReceivePort
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/foundation.dart'; // For debugPrint

// Ensure this path correctly points to your ImageProcessingPayload model
import 'package:reworkmobile/models/isolate_image_data.dart'; 

// Message class to send tasks TO the worker isolate
class FrameProcessingTask {
  final ImageProcessingPayload payload;
  final SendPort replyPort; // Port to send the result back to

  FrameProcessingTask({required this.payload, required this.replyPort});
}

// This is the function that will run INSIDE the worker isolate
String _executeFramePackagingInIsolate(ImageProcessingPayload payload) {
  debugPrint("WORKER_ISOLATE: Packaging frame. Format: ${payload.imageFormatGroupString}, Input Dims: ${payload.width}x${payload.height}, Rotation: ${payload.rotationAngle}, Flip: ${payload.flipHorizontal}");
  
  Stopwatch totalPackagingStopwatch = Stopwatch()..start();
  String yPlaneB64 = "", uPlaneB64 = "", vPlaneB64 = "";
  String bgraPlaneB64 = ""; // If you handle BGRA

  Stopwatch base64Timer = Stopwatch()..start();
  int base64EncodingTimeMs = 0;

  try {
    if (payload.imageFormatGroupString == "yuv420") {
      if (payload.planesBytes.length >= 3) {
        yPlaneB64 = base64Encode(payload.planesBytes[0]);
        uPlaneB64 = base64Encode(payload.planesBytes[1]);
        vPlaneB64 = base64Encode(payload.planesBytes[2]);
      } else {
        throw Exception("Incomplete YUV plane data (planesBytes length < 3)");
      }
    } else if (payload.imageFormatGroupString == "bgra8888") {
      if (payload.planesBytes.isNotEmpty) {
        bgraPlaneB64 = base64Encode(payload.planesBytes[0]);
      } else {
        throw Exception("Incomplete BGRA plane data (planesBytes is empty)");
      }
    } else {
      throw Exception("Unsupported image format: ${payload.imageFormatGroupString}");
    }
  } catch (e) {
     debugPrint("WORKER_ISOLATE: Base64 encoding error: $e");
     base64Timer.stop();
     base64EncodingTimeMs = base64Timer.elapsedMilliseconds;
     totalPackagingStopwatch.stop();
     debugPrint("WORKER_ISOLATE_TIMING (Error in Base64): Total Package attempt: ${totalPackagingStopwatch.elapsedMilliseconds}ms, Base64Attempt: ${base64EncodingTimeMs}ms");
     return jsonEncode({'error': 'Base64 encoding failed in worker: ${e.toString()}'});
  }
  base64Timer.stop();
  base64EncodingTimeMs = base64Timer.elapsedMilliseconds;

  Map<String, dynamic> frameData = {
    'image_format': payload.imageFormatGroupString,
    'width': payload.width,
    'height': payload.height,
    'planes': [], // Will be populated below
    'transform_instructions': {
      'rotation_to_apply_degrees': payload.rotationAngle,
      'flip_horizontal_to_apply': payload.flipHorizontal,
      'intended_crop_strategy': "extract_16_9_landscape_from_upright_portrait",
      'final_target_width': 640,
      'final_target_height': 360,
    },
    'client_timestamp_ms': DateTime.now().millisecondsSinceEpoch,
  };

  if (payload.imageFormatGroupString == "yuv420") {
    // We already checked planesBytes.length >= 3 for base64 encoding
    // Now check bytesPerRow and bytesPerPixel lengths
    if (payload.bytesPerRow.length < 3 || payload.bytesPerPixel.length < 3) {
        totalPackagingStopwatch.stop();
        debugPrint("WORKER_ISOLATE_TIMING (Error): Total Package: ${totalPackagingStopwatch.elapsedMilliseconds}ms");
        return jsonEncode({'error': 'Incomplete YUV stride/bpp data in worker'});
    }
    frameData['planes'] = [
      {'bytes_base64': yPlaneB64, 'row_stride': payload.bytesPerRow[0], 'pixel_stride': payload.bytesPerPixel[0] ?? 1},
      {'bytes_base64': uPlaneB64, 'row_stride': payload.bytesPerRow[1], 'pixel_stride': payload.bytesPerPixel[1] ?? 1},
      {'bytes_base64': vPlaneB64, 'row_stride': payload.bytesPerRow[2], 'pixel_stride': payload.bytesPerPixel[2] ?? 1}
    ];
  } else if (payload.imageFormatGroupString == "bgra8888") {
      if (payload.bytesPerRow.isEmpty || payload.bytesPerPixel.isEmpty) {
          totalPackagingStopwatch.stop();
          debugPrint("WORKER_ISOLATE_TIMING (Error): Total Package: ${totalPackagingStopwatch.elapsedMilliseconds}ms");
          return jsonEncode({'error': 'Incomplete BGRA stride/bpp data in worker'});
      }
      frameData['planes'] = [{'bytes_base64': bgraPlaneB64, 'row_stride': payload.bytesPerRow[0], 'pixel_stride': payload.bytesPerPixel[0] ?? 4}];
  }
  // No need for an 'else' here for unsupported format, as it was caught by the Base64 encoding try-catch

  Stopwatch jsonEncodeTimer = Stopwatch()..start();
  String jsonResult = jsonEncode(frameData);
  jsonEncodeTimer.stop();
  int jsonEncodingTimeMs = jsonEncodeTimer.elapsedMilliseconds;

  totalPackagingStopwatch.stop();
  debugPrint("WORKER_ISOLATE_TIMING: Total Package: ${totalPackagingStopwatch.elapsedMilliseconds}ms, Base64: ${base64EncodingTimeMs}ms, JsonEncode: ${jsonEncodingTimeMs}ms");
  return jsonResult;
}

// Isolate Entry Point for your actual app
void frameProcessorIsolateEntryPoint(SendPort mainSendPort) {
  ReceivePort workerReceivePort = ReceivePort();
  mainSendPort.send(workerReceivePort.sendPort); // Send worker's port to main

  workerReceivePort.listen((dynamic message) {
    if (message is FrameProcessingTask) {
      try {
        String resultJson = _executeFramePackagingInIsolate(message.payload);
        message.replyPort.send(resultJson);
      } catch (e,s) {
        // This catch block is crucial for errors within the isolate task execution
        debugPrint("WORKER_ISOLATE: CRITICAL Uncaught Error during _executeFramePackagingInIsolate: $e\n$s");
        // Try to send an error message back if possible
        try {
            message.replyPort.send(jsonEncode({'error': 'Worker isolate critical execution failed: ${e.toString()}'}));
        } catch (sendError) {
            debugPrint("WORKER_ISOLATE: Failed to send error back to main: $sendError");
        }
      }
    } else {
        debugPrint("WORKER_ISOLATE: Received unknown message type: ${message.runtimeType}");
    }
  });
}