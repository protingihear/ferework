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
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id'); // 🔥 Retrieve user_id

      if (userId == null) {
        print("❌ Error: user_id is null after login.");
        return;
      }

      // ✅ Login successful, navigate with correct userId
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            roomId: "67ce7cb40a1e30fecfc44818",
            userId: userId.toString(), // <-- Ensure this is not null
          ),
        ),
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
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 100,
                    ),
                  ),
                  // SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text('Welcome Back To My Guys'),
                  ),
                  SizedBox(height: 40),

                  // Email/Username TextField
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.green[100],
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Password TextField
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.green[100],
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Checkbox Remember Me
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
                  SizedBox(height: 8),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.purple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () {
                        print('Forgot Password tapped');
                      },
                    ),
                  ),
                  SizedBox(height: 24),

                  // Sign In Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _handleLogin,
                    child: Text('Sign In', style: TextStyle(fontSize: 16)),
                  ),

                  // Menampilkan pesan error jika ada
                  if (_responseMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: Text(
                          _responseMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  SizedBox(height: 16),

                  // Sign Up Button
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Sign_Up_Page()),
                      );
                    },
                    child: Text('Sign Up', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
