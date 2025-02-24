import 'package:flutter/material.dart';
import 'view/animation/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iHear',
      theme: ThemeData.light(), // Optional: Dark theme like YouTube
      home: HomeScreen(), // Start with SplashScreen

    );
  }
}
