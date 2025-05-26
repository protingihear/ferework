import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reworkmobile/services/auth_service.dart';
import 'package:reworkmobile/view/view_wait_verify.dart';
import '../services/data_user.dart';

class Sign_Up_Page extends StatefulWidget {
  const Sign_Up_Page({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<Sign_Up_Page> {
  final _formKey = GlobalKey<FormState>();
  final dataUser = Datauser();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController registEmailController = TextEditingController();
  final TextEditingController registPasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  String? gender;
  String? role;
  bool isAgreed = false;

  final Color softGreen = const Color(0xFFCCFFCC);
  final Color greenAccent = const Color(0xFFB2F2BB);
  final Color white = Colors.white;

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: softGreen,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: _inputDecoration(hint, icon),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFB7E4C7);
    const Color accentColor = Color(0xFF2D6A4F);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 12),
              const Text(
                'IHear',
                style: TextStyle(
                  fontSize: 32,
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign Up for IHear',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const Text(
                'Create your account',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _textField(
                        controller: nameController,
                        hint: 'Nama Lengkap',
                        icon: Icons.person,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nama lengkap mu'
                            : null,
                      ),
                      _textField(
                        controller: usernameController,
                        hint: 'Username',
                        icon: Icons.person_outline,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Username wajib diisi'
                            : null,
                      ),
                      _textField(
                        controller: registEmailController,
                        hint: 'Email',
                        icon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Email wajib diisi';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                            return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      _textField(
                        controller: registPasswordController,
                        hint: 'Password',
                        icon: Icons.lock,
                        obscure: true,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Password wajib diisi';
                          final regex = RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,12}$');
                          if (!regex.hasMatch(value)) {
                            return '8-12 karakter, huruf besar, kecil, angka & simbol';
                          }
                          return null;
                        },
                      ),
                      _textField(
                        controller: confirmPasswordController,
                        hint: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: (value) {
                          if (value != registPasswordController.text)
                            return 'Password tidak cocok';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Jenis Kelamin*',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Laki-laki'),
                              value: 'Laki-laki',
                              groupValue: gender,
                              activeColor: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  gender = value!;
                                });
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Perempuan'),
                              value: 'Perempuan',
                              groupValue: gender,
                              activeColor: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  gender = value!;
                                });
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: isAgreed,
                            activeColor: Colors.green,
                            onChanged: (value) =>
                                setState(() => isAgreed = value ?? false),
                          ),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text('I agree with '),
                                GestureDetector(
                                  onTap: () {
                                    // open terms page
                                  },
                                  child: const Text(
                                    'terms & conditions',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: (isAgreed && gender != null)
                            ? () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    final userCredential = await FirebaseAuth
                                        .instance
                                        .createUserWithEmailAndPassword(
                                      email: registEmailController.text.trim(),
                                      password: registPasswordController.text,
                                    );

                                    await userCredential.user
                                        ?.sendEmailVerification();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EmailVerificationPage(
                                          onVerified: () {
                                            AuthService.registerUser(
                                              context: context,
                                              username: usernameController.text,
                                              email: registEmailController.text
                                                  .trim(),
                                              password:
                                                  registPasswordController.text,
                                              confirmPassword:
                                                  confirmPasswordController
                                                      .text,
                                              fullName: nameController.text,
                                              gender: gender!,
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Terjadi kesalahan: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            : null,
                        child: const Text('Sign Up'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
