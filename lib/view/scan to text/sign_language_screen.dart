import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';

class SignLanguageScreen extends StatefulWidget {
  @override
  _SignLanguageScreenState createState() => _SignLanguageScreenState();
}

class _SignLanguageScreenState extends State<SignLanguageScreen> {
  CameraController? _controller;
  late IOWebSocketChannel _channel;
  String prediction = "Tampilkan hasil teks di sini";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _connectToWebSocket();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.low, // Reduce resolution for efficiency
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }

    _startStreaming();
  }

  void _connectToWebSocket() {
    _channel = IOWebSocketChannel.connect("ws://YOUR_FLASK_SERVER_IP:5000");
    _channel.stream.listen((message) {
      setState(() {
        prediction = message;
      });
    });
  }

  void _startStreaming() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    while (true) {
      try {
        final XFile file = await _controller!.takePicture();
        final Uint8List imageBytes = await file.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        _channel.sink.add(base64Image);
        await Future.delayed(
            Duration(milliseconds: 200)); // Adjust FPS if needed
      } catch (e) {
        print("Error capturing frame: $e");
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Camera Preview (Full Width)
              Expanded(
                flex: 3,
                child: _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      )
                    : Container(color: Colors.grey[300]),
              ),

              // Text Output Box (Correct Height)
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      prediction,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Back Button
          Positioned(
            top: 40, // Adjust position as needed
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // Semi-transparent
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for scanning frame
class ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final double length = 50.0;
    final double thickness = 6.0;

    // Top-left
    canvas.drawLine(Offset(0, thickness), Offset(length, thickness), paint);
    canvas.drawLine(Offset(thickness, 0), Offset(thickness, length), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - length, thickness),
        Offset(size.width, thickness), paint);
    canvas.drawLine(Offset(size.width - thickness, 0),
        Offset(size.width - thickness, length), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height - thickness),
        Offset(length, size.height - thickness), paint);
    canvas.drawLine(Offset(thickness, size.height - length),
        Offset(thickness, size.height), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - length, size.height - thickness),
        Offset(size.width, size.height - thickness), paint);
    canvas.drawLine(Offset(size.width - thickness, size.height - length),
        Offset(size.width - thickness, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
