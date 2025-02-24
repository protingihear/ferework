import 'package:flutter/material.dart';
import 'package:reworkmobile/view/Relation.dart';
import 'package:reworkmobile/view/home.dart';
import 'view/animation/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),  // Set Poppins globally
      ),
      title: 'iHear',
     // Optional: Dark theme like YouTube
      home: RelationsPage(), // Start with SplashScreen

    );
  }
}
