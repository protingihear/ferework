import 'package:flutter/material.dart';
import 'package:reworkmobile/view/Relation.dart';
import 'package:reworkmobile/view/home.dart';
import 'view/animation/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view/home.dart';
import 'package:reworkmobile/main_screen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),  // Set Poppins globally
      ),
      title: 'iHear',
     // Optional: Dark theme like YouTube
      home:RelationsPage(), // Start with SplashScreen

    );
  }
}