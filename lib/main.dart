import 'package:flutter/material.dart';
import 'package:reworkmobile/view/sign_in.dart';
import 'view/animation/splash_screen.dart'; // Import the splash screen file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouTube Style Splash',
      theme: ThemeData.dark(), // Optional: Dark theme like YouTube
      home: Sign_In_Page(), // Start with SplashScreen
    );
  }
}
