// lib/models/isolate_image_data.dart
import 'dart:typed_data';
import 'package:camera/camera.dart'; // For CameraImage in factory, ImageFormatGroup
import 'package:flutter/foundation.dart'; // For debugPrint

// Data structure passed from CameraImage to the isolate for processing/packaging
class ImageProcessingPayload {
  final List<Uint8List> planesBytes;
  final List<int> bytesPerRow;
  final List<int?> bytesPerPixel;
  final int width;
  final int height;
  final String imageFormatGroupString; // "yuv420", "bgra8888"
  
  // Transformation metadata calculated on the client
  final int rotationAngle; // This is your `finalRotationForPortraitStage`
  final bool flipHorizontal;

  ImageProcessingPayload({
    required this.planesBytes,
    required this.bytesPerRow,
    required this.bytesPerPixel,
    required this.width,
    required this.height,
    required this.imageFormatGroupString,
    required this.rotationAngle,
    required this.flipHorizontal,
  });

  factory ImageProcessingPayload.fromCameraImage(
      CameraImage image, int finalRotationAngle, bool doFlipHorizontal) {
    String formatGroup;
    if (image.format.group == ImageFormatGroup.yuv420) {
      formatGroup = "yuv420";
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      formatGroup = "bgra8888";
    } else {
      debugPrint("ImageProcessingPayload: Unsupported image format group ${image.format.group}, defaulting to 'unsupported'.");
      formatGroup = "unsupported"; // Or handle error
    }

    if (image.format.group == ImageFormatGroup.yuv420) {
      formatGroup = "yuv420";
      debugPrint("Client YUV420 Plane Info:");
      for (int i = 0; i < image.planes.length; i++) {
        debugPrint("  Plane $i: bytesPerRow=${image.planes[i].bytesPerRow}, bytesPerPixel=${image.planes[i].bytesPerPixel}, len=${image.planes[i].bytes.lengthInBytes}");
      }
    }

    return ImageProcessingPayload(
      planesBytes: image.planes.map((p) => p.bytes).toList(),
      bytesPerRow: image.planes.map((p) => p.bytesPerRow).toList(),
      bytesPerPixel: image.planes.map((p) => p.bytesPerPixel).toList(),
      width: image.width,
      height: image.height,
      imageFormatGroupString: formatGroup,
      rotationAngle: finalRotationAngle,
      flipHorizontal: doFlipHorizontal,
    );
  }
}

// Data class for WebSocket message content (for parsing responses from backend)
class PredictionResponse {
  final String? gesture;
  final String? status;
  final String? error;
  final double? confidence;
  final int? bufferedFrames;
  final int? neededFrames;
  final bool? isStable;
  final DateTime timestamp;

  PredictionResponse({
    this.gesture,
    this.status,
    this.error,
    this.confidence,
    this.bufferedFrames,
    this.neededFrames,
    this.isStable,
    required this.timestamp,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      gesture: json['gesture'] as String?,
      status: json['status'] as String?,
      error: json['error'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      bufferedFrames: json['buffered_frames'] as int?,
      neededFrames: json['needed_frames'] as int?,
      isStable: json['is_stable'] as bool?,
      timestamp: DateTime.now(),
    );
  }

  String isMeaningfulGesture(String? gestureStr) {
    if (gestureStr == null || gestureStr.isEmpty) return "";
    if (gestureStr == "Uncertain Seq (Low Confidence)" ||
        gestureStr == "Uncertain Seq (Building Streak)" ||
        gestureStr.toLowerCase().contains("unknown") ||
        gestureStr.toLowerCase().contains("uncertain")) { // More robust check for "uncertain"
      return ""; // Not a specific, meaningful gesture name for display alongside meter
    }
    return gestureStr; // It's a specific gesture name
  }

  String toDisplayText() {
    if (error != null && error!.isNotEmpty) {
      return "Error: $error";
    }

    String meaningfulGesture = isMeaningfulGesture(gesture);

    // Priority 1: Stable and meaningful gesture
    if (isStable == true && meaningfulGesture.isNotEmpty) {
      String displayText = meaningfulGesture;
      // You can choose to add confidence back if you like for stable predictions
      // if (confidence != null) {
      //   displayText += " (${confidence!.toStringAsFixed(1)})";
      // }
      return displayText;
    }

    // Priority 2: Progress meter if buffering/building towards a gesture
    if (neededFrames != null && neededFrames! > 0 && bufferedFrames != null) {
      int currentFrames = bufferedFrames! < 0 ? 0 : bufferedFrames!; // Ensure non-negative
      if (currentFrames > neededFrames!) { // Cap currentFrames at neededFrames
          currentFrames = neededFrames!;
      }

      int filledCount = currentFrames;
      int emptyCount = neededFrames! - currentFrames;
      if (emptyCount < 0) emptyCount = 0;

      // Simple text-based meter characters
      String filledChar = "■"; // Solid block
      String emptyChar = "□";  // Empty block
      // Alternative: String filledChar = "●"; String emptyChar = "○";
      // Alternative: String filledChar = "|"; String emptyChar = "-";


      String meterString = '[' + (filledChar * filledCount) + (emptyChar * emptyCount) + ']';

      String label;
      if (meaningfulGesture.isNotEmpty) {
        label = "Trying: $meaningfulGesture";
      } else if (status != null && status!.isNotEmpty && 
                 (status!.toLowerCase().contains("building") || status!.toLowerCase().contains("buffering") || status!.toLowerCase().contains("processing"))) {
        label = status!; // Use status like "Building Streak..."
      } else if (gesture != null && gesture!.isNotEmpty) { // Fallback to any gesture string if status isn't informative
         label = gesture!;
      }
      else {
        label = "Detecting...";
      }
      
      return "$meterString $label";
    }

    // Priority 3: Fallback to status or generic gesture if no meter, not stable but some info exists
    if (meaningfulGesture.isNotEmpty) { // If stable was false, but we got a meaningful gesture (less likely but possible)
        return "Processing: $meaningfulGesture";
    }
    if (gesture != null && gesture!.isNotEmpty) { // Display any gesture string (e.g. "Uncertain Seq...")
        return gesture!;
    }
    if (status != null && status!.isNotEmpty) {
        return status!;
    }
    
    // Default fallback
    return "...";
  }
}
