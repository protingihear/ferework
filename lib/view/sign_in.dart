// import 'package:bisadenger/information.dart';
import 'package:reworkmobile/main_screen.dart';
import 'package:reworkmobile/services/auth_service.dart';
import 'package:reworkmobile/view/animation/splash_screen.dart';
import 'package:reworkmobile/view/home.dart';
import 'package:reworkmobile/view/view_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'home_page.dart';
import 'chat_page.dart';
import 'package:flutter/material.dart';
import 'sign_up.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Sign_In_Page extends StatefulWidget {
  const Sign_In_Page({super.key});

  @override
  _Sign_In_Page createState() => _Sign_In_Page();
}

class _Sign_In_Page extends State<Sign_In_Page> {
  bool isChecked = false;
late SharedPreferences prefs; // Declare prefs

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _responseMessage;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

void _handleLogin() async {
  await _initPrefs(); // Ensure prefs is initialized before using it

  String email = _emailController.text;
  String password = _passwordController.text;

  if (email.isNotEmpty && password.isNotEmpty) {
    String? errorMessage = await _authService.login(email, password);

    if (errorMessage == null) {
      // ✅ Login successful, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()), // <-- Diubah ke HomeScreen
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email dan password tidak boleh kosong!')),
    );
  }
}

@override
Widget build(BuildContext context) {
  bool _obscurePassword = true;

  return SafeArea(
    child: Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 100,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'IHear',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sign In for IHear',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Welcome back!',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Email Field  
             Container(
  decoration: BoxDecoration(
    color: Color(0xFFD3F0D0),
    borderRadius: BorderRadius.circular(30),
  ),
  child: TextField(
    controller: _emailController,
    decoration: InputDecoration(
      hintText: 'Username',
      filled: true,
      fillColor: Color(0xFFD3F0D0),
      prefixIcon: Icon(Icons.email),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    ),
  ),
),

               
              SizedBox(height: 12),

              // Password Field with Visibility Toggle
              Container(
  decoration: BoxDecoration(
    color: Color(0xFFD3F0D0),
    borderRadius: BorderRadius.circular(30),
  ),
  child: TextField(
    controller: _passwordController,
    obscureText: _obscurePassword,
    decoration: InputDecoration(
      hintText: 'Password',
      filled: true,
      fillColor: Color(0xFFD3F0D0),
      prefixIcon: Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    ),
  ),
),

            
              SizedBox(height: 12),

              // Forgot Password
            
Align(
  alignment: Alignment.centerLeft,
  child: GestureDetector(
    onTap: () {
      print('Forgot Password tapped');
    },
    child: Text(
      'Forgot your password?',
      style: TextStyle(
        color: Color(0xFF489042),
         fontWeight: FontWeight.bold,
        
        
      ),
    ),
  ),
),

              SizedBox(height: 12),
              // Remember Me
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                  Text('Remember Me'),
                ],
              ),
              SizedBox(height: 16),

              // Sign In Button
              ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF489042), // Warna hijau
    foregroundColor: Colors.white, // Warna teks
    minimumSize: Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Bisa ubah sesuai selera
    ),
  ),
  onPressed: _handleLogin,
  child: Text(
    'Sign In',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold, // Bold biar lebih tegas
      color: Colors.white,
    ),
  ),
),
              // Error message
              if (_responseMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Text(
                      _responseMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              SizedBox(height: 16),

              // Sign Up
              OutlinedButton(
  style: OutlinedButton.styleFrom(
    backgroundColor: Colors.white, // Background putih
    foregroundColor: Color(0xFF489042), // Warna teks hijau
    side: BorderSide(color: Color(0xFF489042)), // Border hijau
    minimumSize: Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded
    ),
  ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Sign_Up_Page()),
    );
  },
  child: Text(
    'Sign Up',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFF489042),
    ),
  ),
),

             
            ],
          ),
        ),
      ),
    ),
  );
}

}
