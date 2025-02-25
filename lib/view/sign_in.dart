// import 'package:bisadenger/information.dart';
import 'package:reworkmobile/view/animation/splash_screen.dart';
import 'package:reworkmobile/view/home.dart';
import 'package:reworkmobile/view/view_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'home_page.dart';
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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _responseMessage;

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
                    onPressed: login,
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

  Future<bool> hasSessionCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('session_cookie'); // ✅ Check if cookie exists
  }

  // Fungsi login untuk mengecek email dan password
  Future<void> login() async {
  final email = _emailController.text;
  final password = _passwordController.text;

  final url = 'http://10.0.2.2:5000/auth/login';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        final prefs = await SharedPreferences.getInstance();

        // Extract session_id
        final sessionMatch = RegExp(r'session_id=([^;]+)').firstMatch(cookies);
        final sessionId = sessionMatch?.group(1);

        // Extract tt
        final ttMatch = RegExp(r'tt=([^;]+)').firstMatch(cookies);
        final tt = ttMatch?.group(1);

        if (sessionId != null) {
          await prefs.setString('session_cookie', sessionId);
        }
        if (tt != null) {
          await prefs.setString('tt_cookie', tt);
        }

        print("📢 Full Set-Cookie Header: $cookies");
        print("✅ Saved session_id: $sessionId");
        print("✅ Saved tt: $tt");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() {
          _responseMessage = "Login failed: No session cookie received.";
        });
      }
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        _responseMessage =
            "Login failed: ${data['message'] ?? 'Unknown error'}";
      });
    }
  } catch (error) {
    setState(() {
      _responseMessage = "Request failed: $error";
    });
  }
}


}
