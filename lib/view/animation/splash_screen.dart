import 'package:flutter/material.dart';
import 'package:reworkmobile/view/sign_in.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Navigate to sign-in quickly
    Future.delayed(Duration(milliseconds: 800), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Sign_In_Page()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Transform.scale(
          scale: 0.5, // Scale the image 2.5x its normal size
          child: Image.asset(
            "assets/ihear_logo.png",
            width: MediaQuery.of(context).size.width * 0.5,
            fit: BoxFit.contain,
          ),
        ),

      ),
    );
  }
}
