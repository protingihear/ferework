import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationPage extends StatefulWidget {
  final VoidCallback onVerified;

  const EmailVerificationPage({super.key, required this.onVerified});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
  }

  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      timer.cancel();
      widget.onVerified();
      Navigator.pop(context); // kembali setelah register ke backend
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB7E4C7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read_rounded, size: 80, color: Colors.green.shade800),
            const SizedBox(height: 24),
            Text(
              'Periksa email kamu!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Kami sudah mengirim email verifikasi. Harap verifikasi untuk menyelesaikan pendaftaran.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.green),
            const SizedBox(height: 8),
            Text('Menunggu verifikasi...', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
