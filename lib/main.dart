import 'package:flutter/material.dart';
import 'view/animation/splash_screen.dart'; // Import the splash screen file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouTube Style Splash',
      theme: ThemeData.dark(), // Optional: Dark theme like YouTube
      home: SplashScreen(), // Start with SplashScreen
    );
  }
}
