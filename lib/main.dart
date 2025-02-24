import 'package:flutter/material.dart';
import 'package:reworkmobile/view/postberita.dart';
import 'package:reworkmobile/view/sign_in.dart';
import 'package:reworkmobile/view/home.dart';
import 'package:reworkmobile/view/berita.dart';

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
      theme: ThemeData.light(), // Optional: Dark theme like YouTube
      home: HomeScreen(), // Start with SplashScreen

    );
  }
}
