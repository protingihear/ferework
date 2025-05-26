import 'package:flutter/material.dart';
import 'package:reworkmobile/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/view/sign_in.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId != null) {
      // Sudah login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // Belum login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Sign_In_Page()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Transform.scale(
          scale: 0.5,
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
