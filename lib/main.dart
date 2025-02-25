import 'package:flutter/material.dart';
import 'package:reworkmobile/services/auth_service.dart';
import 'package:reworkmobile/view/postberita.dart';
import 'package:reworkmobile/view/sign_in.dart';
import 'package:reworkmobile/view/home.dart';
import 'package:reworkmobile/view/berita.dart';

import 'view/animation/splash_screen.dart';

void main() async {
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
      home: SplashScreen(), // Start with SplashScreen

    );
  }
}
