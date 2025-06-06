// lib/view/scan_to_text.dart
import 'dart:async';
import 'dart:convert'; // For jsonDecode, jsonEncode (error handling)
import 'dart:isolate'; // For Isolate, SendPort, ReceivePort
import 'dart:typed_data'; // For Uint8List (though not directly used for preview now)

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart'; // For DeviceOrientation
import 'package:reworkmobile/services/image_processing_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:reworkmobile/models/isolate_image_data.dart';

class CutoutGuideOverlayPainter extends CustomPainter {
  final Rect guideRect; // This is the 16:9 clear area
  final Paint backgroundPaint; // For the area outside the guideRect
  final Paint borderPaint; // Optional border for the clear guideRect

  CutoutGuideOverlayPainter({
    required this.guideRect,
    Color overlayBackgroundColor = Colors.white, // Default to white
    Color guideBorderColor =
        Colors.transparent, // Default to no border for the clear area
    double guideBorderWidth = 0.0, // Default to no border
  })  : backgroundPaint = Paint()..color = overlayBackgroundColor,
        borderPaint = Paint()
          ..color = guideBorderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = guideBorderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // If guideRect is invalid or too small, fill the whole screen with the background color
    if (guideRect.isEmpty || guideRect.width <= 0 || guideRect.height <= 0) {
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
      return;
    }

    // Path for the entire screen
    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Path for the clear guide rectangle (where the camera view will be visible)
    final clearGuidePath = Path()..addRect(guideRect);

    // Create the path for the areas to be covered by the background color
    // This is done by taking the difference between the full screen and the clear guide area
    final backgroundAreaPath =
        Path.combine(PathOperation.difference, fullScreenPath, clearGuidePath);

    // Draw the background (e.g., white) in the areas outside the guideRect
    canvas.drawPath(backgroundAreaPath, backgroundPaint);

    // Optionally, draw a border around the clear guide rectangle
    if (borderPaint.strokeWidth > 0 && borderPaint.color.alpha > 0) {
      canvas.drawRect(guideRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CutoutGuideOverlayPainter oldDelegate) {
    return oldDelegate.guideRect != guideRect ||
        oldDelegate.backgroundPaint.color != backgroundPaint.color ||
        oldDelegate.borderPaint.color != borderPaint.color ||
        oldDelegate.borderPaint.strokeWidth != borderPaint.strokeWidth;
  }
}

class SignDetectionPage extends StatefulWidget {
  const SignDetectionPage({super.key});
  @override
  _SignDetectionPageState createState() => _SignDetectionPageState();
}

class _SignDetectionPageState extends State<SignDetectionPage> {
  CameraController? _cameraController;
  CameraDescription? _frontCamera;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  WebSocketChannel? _webSocketChannel;
  String _predictionText = "Tap 'Start Detection'";
  final String _webSocketURI =
      "ws://4.216.184.229:8000/ws_predict_sequence"; // Your local IP
  final int _framesPerSecondToSendToBackend = 5;
  late final int _frameSendIntervalMs;
  DateTime? _lastFrameProcessingAttemptTime; // Renamed for clarity
  int _conversionTimeMs =
      0; // This will now be the round-trip time for the isolate task
  Image?
      _debugFramePreview; // Will remain null as client doesn't generate preview
  int _processedFrameCounter = 0;
  String _lastError = "";

  int _cameraSensorOrientation = 0;
  final bool _doFlipFrontCameraImageHorizontally = true;

  // Persistent Isolate variables
  Isolate? _frameProcessingIsolate;
  SendPort? _toFrameWorkerSendPort; // To send tasks to the worker
  ReceivePort?
      _fromFrameWorkerSetupPort; // For initial setup to get worker's SendPort

  // Lock to prevent sending new tasks to isolate if one is already being processed by it
  // (or waiting for its reply).
  bool _isWaitingForIsolateResult = false;

  final Stopwatch _taskRoundTripStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _frameSendIntervalMs = (1000 / _framesPerSecondToSendToBackend).round();
    _initializeCamera();
    _spawnFrameProcessingIsolate(); // Spawn isolate on init
  }

  Future<void> _initializeCamera() async {
    if (mounted) setState(() => _isCameraInitialized = false);
    if (_cameraController != null) {
      if (_cameraController!.value.isStreamingImages) {
        try {
          await _cameraController!.stopImageStream();
        } catch (e) {
          debugPrint("Error stopping previous stream: $e");
        }
      }
      await _cameraController!.dispose();
      _cameraController = null;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _predictionText = "No cameras available.");
        return;
      }
      _frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first);
      _cameraSensorOrientation = _frontCamera?.sensorOrientation ?? 0;
    } catch (e) {
      if (mounted)
        setState(() => _predictionText = "Error finding cameras: $e");
      return;
    }
    if (_frontCamera == null) {
      if (mounted)
        setState(() => _predictionText = "Could not select front camera.");
      return;
    }

    _cameraController = CameraController(
      _frontCamera!,
      ResolutionPreset.low, // Using low as per your logs (320x240)
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // Explicitly request YUV
    );
    try {
      await _cameraController!.initialize();
      await _cameraController!
          .lockCaptureOrientation(DeviceOrientation.portraitUp);
      debugPrint(
          "INIT: Cam initialized. Req Preset: low. Actual Preview: ${_cameraController?.value.previewSize}, SensorOrientation: $_cameraSensorOrientation");
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
        _predictionText = "Ready.";
      });
    } catch (e) {
      final errorMsg = e is CameraException ? e.description : e.toString();
      if (mounted)
        setState(() {
          _predictionText = "Camera Error: ${errorMsg ?? 'Unknown'}";
          _isCameraInitialized = false;
          _cameraController = null;
        });
    }
  }

  Future<void> _spawnFrameProcessingIsolate() async {
    if (_frameProcessingIsolate != null) {
      debugPrint("Frame Processing Isolate: Already running.");
      return;
    }
    _fromFrameWorkerSetupPort = ReceivePort();
    try {
      _frameProcessingIsolate = await Isolate.spawn(
          frameProcessorIsolateEntryPoint, _fromFrameWorkerSetupPort!.sendPort,
          errorsAreFatal: true, // Good for debugging initially
          onError: _fromFrameWorkerSetupPort!.sendPort,
          onExit: _fromFrameWorkerSetupPort!.sendPort);
      debugPrint("Frame Processing Isolate: Spawn initiated.");

      _fromFrameWorkerSetupPort!.listen((dynamic message) {
        if (!mounted) return; // Check if widget is still in tree

        if (message is SendPort) {
          _toFrameWorkerSendPort = message;
          debugPrint(
              "Frame Processing Isolate: Received worker's SendPort. Ready for tasks.");
        } else if (message is List &&
            message.length == 2 &&
            message[0] == "ERROR") {
          debugPrint(
              "Frame Processing Isolate: Error from worker during setup: ${message[1]}");
          _lastError = "Worker Isolate Setup Error: ${message[1]}";
        } else if (message is List &&
            message.length == 2 &&
            message[0] == "EXIT") {
          debugPrint(
              "Frame Processing Isolate: Worker exited with message: ${message[1]}");
          _lastError = "Worker Isolate Exited: ${message[1]}";
          _frameProcessingIsolate = null;
          _toFrameWorkerSendPort = null;
          _fromFrameWorkerSetupPort?.close(); // Close the setup port
          _fromFrameWorkerSetupPort = null;
          // Optionally, try to respawn if needed and if detection is active
          // if (_isDetecting) _spawnFrameProcessingIsolate();
        } else {
          debugPrint(
              "Frame Processing Isolate: Received unknown message on setup port: $message");
        }
        if (mounted) setState(() {});
      }, onDone: () {
        debugPrint("Frame Processing Isolate: Setup port closed.");
        _fromFrameWorkerSetupPort = null;
      }, onError: (error) {
        debugPrint(
            "Frame Processing Isolate: Error on setup port listener: $error");
        _fromFrameWorkerSetupPort = null;
      });
    } catch (e, s) {
      debugPrint("Frame Processing Isolate: Error spawning: $e\n$s");
      _fromFrameWorkerSetupPort?.close();
      _fromFrameWorkerSetupPort = null;
      if (mounted)
        setState(() {
          _lastError = "Failed to spawn worker: $e";
        });
    }
  }

  void _killFrameProcessingIsolate() {
    debugPrint("Frame Processing Isolate: Attempting to kill...");
    _fromFrameWorkerSetupPort?.close();
    _fromFrameWorkerSetupPort = null;
    _frameProcessingIsolate?.kill(priority: Isolate.immediate);
    _frameProcessingIsolate = null;
    _toFrameWorkerSendPort = null;
    debugPrint("Frame Processing Isolate: Killed.");
    if (mounted) setState(() {}); // Update UI if needed
  }

  void _connectWebSocket() {
    if (_webSocketChannel != null && _webSocketChannel!.closeCode == null)
      return;
    try {
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(_webSocketURI));
      if (mounted) setState(() => _predictionText = "Connecting...");

      _webSocketChannel!.stream.listen(
        (message) {
          if (!mounted) return;
          try {
            final decodedMessage = jsonDecode(message as String);
            final prediction = PredictionResponse.fromJson(decodedMessage);
            if (mounted)
              setState(() => _predictionText = prediction.toDisplayText());
          } catch (e) {
            if (mounted) setState(() => _predictionText = "Parse Error: $e");
            debugPrint("WebSocket message parse error: $e. Message: $message");
          }
        },
        onError: (error) {
          if (!mounted) return;
          debugPrint("WebSocket Error: $error");
          if (mounted)
            setState(() {
              _predictionText = "WS Error. Retry.";
              if (_isDetecting)
                _stopProcessingFrames(
                    false); // Stop stream, not full detection logic
              _isDetecting = false; // To be safe, update detection state
              _lastError = "WS Error: $error";
            });
          _webSocketChannel = null;
        },
        onDone: () {
          if (!mounted) return;
          debugPrint("WebSocket Closed by server.");
          if (mounted)
            setState(() {
              _predictionText = "WS Closed. Retry.";
              if (_isDetecting) _stopProcessingFrames(false);
              _isDetecting = false;
              _lastError = "WS Closed by server";
            });
          _webSocketChannel = null;
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) setState(() => _predictionText = "WS Connection Failed: $e");
      debugPrint("WebSocket connection failed: $e");
    }
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    final nowForThrottling = DateTime.now();
    if (_lastFrameProcessingAttemptTime != null &&
        nowForThrottling.difference(_lastFrameProcessingAttemptTime!) <
            Duration(milliseconds: _frameSendIntervalMs)) {
      return; // Throttle based on desired FPS
    }

    if (!_isDetecting ||
        !mounted ||
        _isWaitingForIsolateResult ||
        _toFrameWorkerSendPort == null) {
      if (_isWaitingForIsolateResult && _isDetecting) {
        // This means the previous frame's processing is still ongoing (waiting for isolate reply).
        // debugPrint("Frame dropped: Waiting for previous isolate result.");
      }
      if (_toFrameWorkerSendPort == null && _isDetecting) {
        // debugPrint("Frame dropped: Worker isolate not ready yet.");
      }
      return;
    }

    _isWaitingForIsolateResult =
        true; // Set lock: we are now waiting for this frame's result
    _lastFrameProcessingAttemptTime = nowForThrottling;
    final int currentFrameNumber = ++_processedFrameCounter;

    _taskRoundTripStopwatch.reset();
    _taskRoundTripStopwatch.start();

    String resultJsonFromIsolate = "";

    try {
      int r0_sensorCorrectionToUprightPortrait = 0;
      if (_cameraSensorOrientation == 90)
        r0_sensorCorrectionToUprightPortrait = -90;
      else if (_cameraSensorOrientation == 270)
        r0_sensorCorrectionToUprightPortrait = 90;
      else if (_cameraSensorOrientation == 180)
        r0_sensorCorrectionToUprightPortrait = 180;
      int finalRotationForPortraitStage =
          (r0_sensorCorrectionToUprightPortrait + 180) % 360;

      final payload = ImageProcessingPayload.fromCameraImage(cameraImage,
          finalRotationForPortraitStage, _doFlipFrontCameraImageHorizontally);

      // debugPrint("MAIN_ISOLATE: Sending frame #$currentFrameNumber to persistent worker.");

      ReceivePort replyPort =
          ReceivePort(); // Temporary port for this specific task's reply
      FrameProcessingTask task =
          FrameProcessingTask(payload: payload, replyPort: replyPort.sendPort);

      _toFrameWorkerSendPort!.send(task);

      // Wait for the result from this specific task
      var result = await replyPort.first;
      replyPort.close(); // Close the temporary reply port

      if (result is String) {
        resultJsonFromIsolate = result;
      } else {
        throw Exception(
            "Worker returned unexpected data type: ${result.runtimeType}");
      }

      _taskRoundTripStopwatch.stop();
      final int actualRoundTripTimeMs =
          _taskRoundTripStopwatch.elapsedMilliseconds;

      // This log now includes the WORKER_ISOLATE_TIMING from within the JSON if successful
      debugPrint(
          "Persistent Isolate Round Trip for frame #$currentFrameNumber took: $actualRoundTripTimeMs ms. Result (first 100): ${resultJsonFromIsolate.length > 100 ? resultJsonFromIsolate.substring(0, 100) : resultJsonFromIsolate}");

      if (!mounted) {
        _isWaitingForIsolateResult = false;
        return;
      }

      _debugFramePreview = null;
      String clientSideErrorForState = "";

      if (resultJsonFromIsolate.startsWith('{"error":')) {
        try {
          final errorJson = jsonDecode(resultJsonFromIsolate);
          clientSideErrorForState = "Worker Error: ${errorJson['error']}";
        } catch (_) {
          clientSideErrorForState =
              "Worker returned unparsable error: $resultJsonFromIsolate";
        }
        debugPrint("Error from Worker Isolate: $clientSideErrorForState");
      } else if (resultJsonFromIsolate.isEmpty) {
        clientSideErrorForState = "Worker returned empty result";
      }

      if (mounted) {
        setState(() {
          _conversionTimeMs = actualRoundTripTimeMs;
          _lastError = clientSideErrorForState;
        });
      }

      if (resultJsonFromIsolate.isNotEmpty &&
          clientSideErrorForState.isEmpty &&
          _webSocketChannel != null &&
          _webSocketChannel!.closeCode == null) {
        _webSocketChannel!.sink.add(resultJsonFromIsolate);
        // debugPrint("Frame #$currentFrameNumber (Full JSON data) sent to WebSocket.");
      }
    } catch (e, stackTrace) {
      _taskRoundTripStopwatch.stop(); // Stop timer on error too
      final int errorTimeMs = _taskRoundTripStopwatch.elapsedMilliseconds;
      debugPrint(
          "!!! MAIN_ISOLATE _processCameraImage Error for frame #$currentFrameNumber: $e\n$stackTrace");
      if (mounted) {
        setState(() {
          _conversionTimeMs = errorTimeMs; // Or some indicator of error
          _debugFramePreview = null;
          _lastError = "Client Main Isolate Error during processing: $e";
        });
      }
    } finally {
      _isWaitingForIsolateResult = false; // Release lock
    }
  }

  void _startProcessingFrames() {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      debugPrint("StartProcessing: Camera not ready.");
      return;
    }
    if (_cameraController!.value.isStreamingImages) {
      debugPrint("StartProcessing: Stream already started.");
      return;
    }
    if (_toFrameWorkerSendPort == null) {
      debugPrint(
          "StartProcessing: Worker isolate not ready. Attempting to spawn.");
      _spawnFrameProcessingIsolate(); // Try to spawn if not ready
      // Optionally, delay starting stream or show a message
      // For now, we'll let the _processCameraImage check handle it.
    }

    _processedFrameCounter = 0;
    if (mounted)
      setState(() {
        _lastError = "";
        _conversionTimeMs = 0;
        _debugFramePreview = null;
      });

    _cameraController!.startImageStream(_processCameraImage).then((_) {
      debugPrint("STREAM: Image stream started successfully.");
    }).catchError((e, s) {
      debugPrint("!!! STREAM: Error starting image stream: $e\n$s");
      if (mounted)
        setState(() {
          _predictionText = "Error starting stream: $e";
          _lastError = "Stream Start Err: $e";
        });
    });
  }

  void _stopProcessingFrames([bool resetDetectionState = true]) {
    // Added optional param
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        !_cameraController!.value.isStreamingImages) {
      // debugPrint("StopProcessing: Stream not active or camera not ready.");
      return;
    }
    _cameraController!.stopImageStream().catchError((e) {
      debugPrint("Error stopping stream: $e");
    });
    debugPrint("STREAM: Image stream stopped.");
    if (resetDetectionState) {
      // Only reset if it's a full stop
      if (mounted)
        setState(() {
          _isWaitingForIsolateResult = false;
        });
    }
  }

  void _toggleDetection() {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Camera not ready.")));
      return;
    }

    setState(() {
      _isDetecting = !_isDetecting;
      if (_isDetecting) {
        _predictionText = "Starting detection...";
        if (_toFrameWorkerSendPort == null) {
          // If worker died or not ready
          _spawnFrameProcessingIsolate(); // Try to (re)spawn
        }
        if (_webSocketChannel == null || _webSocketChannel!.closeCode != null) {
          _connectWebSocket();
        }
        _startProcessingFrames();
      } else {
        _predictionText = "Detection stopped.";
        _stopProcessingFrames();
        // Don't kill worker here, it's persistent for the page lifecycle
        // _killFrameProcessingIsolate(); // Only if you want to kill on every stop
        if (mounted)
          setState(() {
            _conversionTimeMs = 0;
            _debugFramePreview = null;
            _processedFrameCounter = 0;
          });
      }
    });
  }

  // In your _SignDetectionPageState class:

  @override
Widget build(BuildContext context) {
  Widget cameraDisplayAreaWithOverlay;

  // --- [CAMERA INITIALIZATION AND guideRectForPainter CALCULATION] ---
  // This entire block of logic that calculates `guideRectForPainter`
  // MUST BE KEPT EXACTLY AS IT WAS IN YOUR PREVIOUS WORKING VERSION.
  // I am re-inserting it here for completeness.
  if (_isCameraInitialized &&
      _cameraController != null &&
      _cameraController!.value.isInitialized &&
      _cameraController!.value.previewSize != null) {
    cameraDisplayAreaWithOverlay = LayoutBuilder(
      builder: (context, constraints) {
        final double previewContainerWidth = constraints.maxWidth;
        final double previewContainerHeight = constraints.maxHeight;
        final Size cameraRawPreviewSize =
            _cameraController!.value.previewSize!;

        // START OF COPIED LOGIC FOR guideRectForPainter
        int r0_sensorCorrection = 0;
        if (_cameraSensorOrientation == 90)
          r0_sensorCorrection = -90;
        else if (_cameraSensorOrientation == 270)
          r0_sensorCorrection = 90;
        else if (_cameraSensorOrientation == 180) r0_sensorCorrection = 180;
        final int backendRotationDegrees = (r0_sensorCorrection + 180) % 360;

        double W_b_in, H_b_in;
        if (backendRotationDegrees == 90 || backendRotationDegrees == 270) {
          W_b_in = cameraRawPreviewSize.height;
          H_b_in = cameraRawPreviewSize.width;
        } else {
          W_b_in = cameraRawPreviewSize.width;
          H_b_in = cameraRawPreviewSize.height;
        }

        if (W_b_in <= 0 || H_b_in <= 0) {
          return CameraPreview(_cameraController!);
        }

        double target_w_16_9_on_backend_image;
        double target_h_16_9_on_backend_image;
        double offset_x_16_9_on_backend_image;
        double offset_y_16_9_on_backend_image;

        if (H_b_in > W_b_in) {
          target_w_16_9_on_backend_image = W_b_in;
          target_h_16_9_on_backend_image = (W_b_in * 9.0 / 16.0);
          if (target_h_16_9_on_backend_image <= 0)
            target_h_16_9_on_backend_image = 1.0;
          if (target_h_16_9_on_backend_image > H_b_in)
            target_h_16_9_on_backend_image = H_b_in;
          offset_y_16_9_on_backend_image =
              (H_b_in - target_h_16_9_on_backend_image) / 2.0;
          offset_x_16_9_on_backend_image = 0.0;
        } else {
          target_h_16_9_on_backend_image = H_b_in;
          target_w_16_9_on_backend_image = (H_b_in * 16.0 / 9.0);
          if (target_w_16_9_on_backend_image <= 0)
            target_w_16_9_on_backend_image = 1.0;
          if (target_w_16_9_on_backend_image > W_b_in)
            target_w_16_9_on_backend_image = W_b_in;
          offset_x_16_9_on_backend_image =
              (W_b_in - target_w_16_9_on_backend_image) / 2.0;
          offset_y_16_9_on_backend_image = 0.0;
        }
        if (offset_x_16_9_on_backend_image < 0)
          offset_x_16_9_on_backend_image = 0.0;
        if (offset_y_16_9_on_backend_image < 0)
          offset_y_16_9_on_backend_image = 0.0;

        final double sourceDisplayWidthForScale = W_b_in;
        final double sourceDisplayHeightForScale = H_b_in;
        final double scaleX =
            previewContainerWidth / sourceDisplayWidthForScale;
        final double scaleY =
            previewContainerHeight / sourceDisplayHeightForScale;
        final double actualDisplayScale = (scaleX < scaleY) ? scaleX : scaleY;
        final double renderedImageWidthOnScreen =
            sourceDisplayWidthForScale * actualDisplayScale;
        final double renderedImageHeightOnScreen =
            sourceDisplayHeightForScale * actualDisplayScale;
        final double letterboxOffsetX =
            (previewContainerWidth - renderedImageWidthOnScreen) / 2.0;
        final double letterboxOffsetY =
            (previewContainerHeight - renderedImageHeightOnScreen) / 2.0;

        final Rect guideRectForPainter = Rect.fromLTWH(
          (offset_x_16_9_on_backend_image * actualDisplayScale) +
              letterboxOffsetX,
          (offset_y_16_9_on_backend_image * actualDisplayScale) +
              letterboxOffsetY,
          target_w_16_9_on_backend_image * actualDisplayScale,
          target_h_16_9_on_backend_image * actualDisplayScale,
        );
        // END OF COPIED LOGIC
        // --- [END OF guideRectForPainter CALCULATION] ---

        return Stack(
          alignment: Alignment.center,
          children: [
            CameraPreview(_cameraController!),
            CustomPaint(
              size: Size(previewContainerWidth, previewContainerHeight),
              painter: CutoutGuideOverlayPainter( // Ensure CutoutGuideOverlayPainter is defined
                guideRect: guideRectForPainter,
                overlayBackgroundColor: Colors.white,
                guideBorderColor: Colors.grey.shade300,
                guideBorderWidth: 0.5,
              ),
            ),
          ],
        );
      },
    );
  } else {
    cameraDisplayAreaWithOverlay = const Center( /* ... your loading UI ... */ );
  }

  final screenHeight = MediaQuery.of(context).size.height;
  // This targetFontSize is for FittedBox. FittedBox will try to achieve this size
  // if width permits and then scale down if height is constrained.
  // Since we are making the text container non-Expanded, its height will be based on this.
  final double targetFontSize = screenHeight / 9; // Made divisor smaller for even larger target font

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar( /* ... AppBar setup ... */ ),
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Camera View Area
          Expanded( // This will now take ALL available flexible space
            child: Container(
              color: Colors.black,
              child: cameraDisplayAreaWithOverlay,
            ),
          ),

          // Prediction Text Area - NOT Expanded anymore
          Container( // Takes height based on its content
            color: Colors.white,
            // Reduced vertical padding to bring it closer to the camera view
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: Center( // Center horizontally
              child: FittedBox( // Scales text to fit available width primarily
                fit: BoxFit.scaleDown, // Use scaleDown to prevent upscaling if font is too small for width
                child: Text(
                  _isDetecting &&
                          _predictionText != "Starting detection..." &&
                          _predictionText != "Ready." &&
                          _predictionText != "Connecting..." &&
                          !_predictionText.toLowerCase().contains("error") &&
                          !_predictionText.toLowerCase().contains("closed")
                      ? _predictionText
                      : (_predictionText == "Tap 'Start Detection'" ||
                              _predictionText == "Detection stopped."
                          ? "..."
                          : _predictionText),
                  style: TextStyle(
                    fontSize: targetFontSize < 60 ? 60 : targetFontSize, // Min font size of 60
                    fontWeight: FontWeight.w900,
                    color: Colors.blueGrey[900],
                    letterSpacing: -2.5, // Adjust for very large fonts
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1, // Important for predictable height with FittedBox
                  softWrap: false,
                ),
              ),
            ),
          ),


            // Stats and Button Area (Non-Expanded, takes fixed height)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(
                  20.0, 4.0, 20.0, 8.0), // Reduced vertical padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isDetecting ||
                      _conversionTimeMs > 0 ||
                      _lastError.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0), // Space to button
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isDetecting || _conversionTimeMs > 0)
                            Text(
                              "Frame: $_processedFrameCounter | Latency: $_conversionTimeMs ms",
                              style: TextStyle(
                                  fontSize: 9, color: Colors.grey[600]),
                            ),
                          if (_lastError.isNotEmpty &&
                              (_isDetecting || _conversionTimeMs > 0))
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3.0),
                              child: Text("|",
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.grey[400])),
                            ),
                          if (_lastError.isNotEmpty)
                            Expanded(
                              child: Text(
                                "Error: $_lastError",
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.redAccent),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ElevatedButton.icon(
                    icon: Icon(
                      _isDetecting
                          ? Icons.stop_circle_rounded
                          : Icons.play_circle_fill_rounded,
                      size: 24, // Slightly smaller icon if space is tight
                      color: Colors.white,
                    ),
                    onPressed: _isCameraInitialized ? _toggleDetection : null,
                    label: Text(
                        _isDetecting ? "STOP DETECTION" : "START DETECTION",
                        style: const TextStyle(
                            fontSize: 15, // Slightly smaller button text
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _isDetecting
                            ? Colors.red.shade700
                            : Colors.green.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(
                            double.infinity, 50), // Keep button reasonably tall
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10))), // Standard rounding
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).padding.bottom > 0
                          ? 0
                          : 8), // Minimal bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
