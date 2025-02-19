import 'package:flutter/material.dart';
import '../services/data_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Sign_Up_Page extends StatefulWidget {
  const Sign_Up_Page({super.key});

  @override
  sign_up createState() => sign_up();
}

class sign_up extends State<Sign_Up_Page> {
  final dataUser = Datauser();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController registEmailController = TextEditingController();
  final TextEditingController registPasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String? gender; // Jenis kelamin ("L" atau "P")
  String? role;
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset(
                //   'assets/logo.png',
                //   height: 100,
                // ),
                SizedBox(height: 30),
                Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('Create your account'),
                SizedBox(height: 16),

                // Name Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.green[100],
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Username Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.green[100],
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: registEmailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.green[100],
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: registPasswordController,
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
                SizedBox(height: 12),

                // Confirm Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.green[100],
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 16),

                // Gender Selection
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Jenis Kelamin*',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Pria'),
                        value: 'L',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Wanita'),
                        value: 'P',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                //Role Selection
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Pilih Peran*',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize
                          .min, // Mengurangi ruang kosong di antara children
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Ahli Bahasa'),
                            value: 'ahli_bahasa',
                            groupValue: role,
                            onChanged: (value) {
                              setState(() {
                                role = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Teman Tuli'),
                            value: 'teman_tuli',
                            groupValue: role,
                            onChanged: (value) {
                              setState(() {
                                role = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    RadioListTile<String>(
                      title: Text('Teman Dengar'),
                      value: 'teman_dengar',
                      groupValue: role,
                      onChanged: (value) {
                        setState(() {
                          role = value;
                        });
                      },
                    ),
                  ],
                ),

                // Terms and Conditions Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: isAgreed,
                      onChanged: (value) {
                        setState(() {
                          isAgreed = value ?? false;
                        });
                      },
                    ),
                    Text('I agree with '),
                    GestureDetector(
                      onTap: () {
                        // Buka halaman syarat dan ketentuan
                      },
                      child: Text(
                        'terms and conditions',
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Sign Up Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isAgreed && gender != null
                      ? () async {
                          String inputUsername = usernameController.text;
                          String inputEmail = registEmailController.text;
                          String inputPassword = registPasswordController.text;
                          String confirmPassword =
                              confirmPasswordController.text;
                          String fullName = nameController.text;

                          if (inputPassword != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Password dan konfirmasi tidak cocok!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          List<String> nameParts =
                              fullName.split(" "); 
                          String firstname =
                              nameParts.first;
                          String lastname =
                              nameParts.skip(1).join(" ");

                          Map<String, dynamic> requestData = {
                            'firstname': firstname,
                            'lastname': lastname,
                            'email': inputEmail,
                            'username': inputUsername,
                            'password': inputPassword,
                            'role': role ?? 'user',
                          };

                          print("Request Data: ${jsonEncode(requestData)}");

                          try {
                            var response = await http.post(
                              Uri.parse(
                                  'https://berework-production.up.railway.app/auth/register'),
                              headers: {
                                'Content-Type': 'application/json',
                              },
                              body: jsonEncode(requestData),
                            );

                            if (response.statusCode == 201) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sign Up Berhasil'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              var errorResponse = jsonDecode(response.body);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error: ${errorResponse['message'] ?? 'Terjadi kesalahan'}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Terjadi kesalahan jaringan: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                  child: Text('Sign Up', style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 12),

                // Cancel Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  },
                  child: Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
