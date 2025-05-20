import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

late SharedPreferences prefs;

Future<void> initPrefs() async {
  prefs = await SharedPreferences.getInstance();
}

class AuthService {
  static const String _baseUrl =
      'https://berework-production-ad0a.up.railway.app';

  // Pakai http.Client untuk persist cookie
  final http.Client _client = http.Client();

  /// Mengecek apakah session cookie ada di penyimpanan lokal
  Future<bool> hasSessionCookie() async {
    return prefs.containsKey('session_cookie');
  }

  /// Mengambil session yang tersimpan
  Future<String?> getSessionCookie() async {
    return prefs.getString('session_cookie');
  }

  /// Fungsi Login
  Future<String?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await _client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": email, "password": password}),
      );

      print("🔍 Status Code: ${response.statusCode}");
      print("📜 Headers: ${response.headers}");
      print("📜 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final cookies = response.headers['set-cookie'];
        print("📢 Full Set-Cookie Header: $cookies");

        final json = jsonDecode(response.body);
        final user = json['user'];

        if (cookies != null) {
          final prefs = await SharedPreferences.getInstance();

          final sessionMatch =
              RegExp(r'session_id=([^;]+)').firstMatch(cookies);
          final ttMatch = RegExp(r'tt=([^;]+)').firstMatch(cookies);

          final sessionId = sessionMatch?.group(1);
          final tt = ttMatch?.group(1);

          print("📢 Ditemukan session_id: $sessionId");
          print("📢 Ditemukan tt: $tt");

          if (sessionId != null) {
            await prefs.setString('session_cookie', sessionId);
          }
          if (tt != null) {
            await prefs.setString('tt_cookie', tt);
          }
          if (user != null) {
            final userId = user['id'];
            await prefs.setInt('user_id', userId);
            print('✅ User ID berhasil disimpan: $userId');

            // // ✅ Ambil FCM token
            // final fcmToken = await FirebaseMessaging.instance.getToken();
            // print('📱 FCM Token: $fcmToken');

            // // ✅ Kirim token ke Firestore (atau ke backend kalau kamu pakai API)
            // if (fcmToken != null) {
            //   await FirebaseFirestore.instance
            //       .collection('users')
            //       .doc(userId.toString())
            //       .set({'fcm_token': fcmToken}, SetOptions(merge: true));
            //   print("✅ Token FCM berhasil disimpan ke Firestore.");
            // } else {
            //   print("⚠️ Token FCM null");
            // }
          }

          return null; // Login berhasil
        } else {
          return "Login gagal: Cookie tidak diterima dari server.";
        }
      } else {
        final data = jsonDecode(response.body);
        return "Login gagal: ${data['message'] ?? 'Kesalahan tidak diketahui'}";
      }
    } catch (error) {
      return "Request gagal: $error";
    }
  }

  /// Fungsi Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_cookie');

    if (sessionId != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Cookie': 'session_id=$sessionId',
          },
        );

        if (response.statusCode == 200) {
          // Clear cookies dari local storage
          await prefs.remove('session_cookie');
          await prefs.remove('tt_cookie');
          print('Logout berhasil.');
        } else {
          print('Logout gagal. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Terjadi kesalahan saat logout: $e');
      }
    } else {
      print('Session ID tidak ditemukan.');
    }
  }

  static Future<void> registerUser({
    required BuildContext context,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required String gender,
  }) async {
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password dan konfirmasi tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<String> nameParts = fullName.split(" ");
    String firstname = nameParts.first;
    String lastname = nameParts.skip(1).join(" ");

    Map<String, dynamic> requestData = {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'username': username,
      'password': password,
      'role': 'user',
      'bio': 'Hallo, aku adalah pengguna baru IHear',
      'gender': gender
    };

    print("Request Data: ${jsonEncode(requestData)}");

    try {
      var response = await http.post(
        Uri.parse(
            'https://berework-production-ad0a.up.railway.app/auth/register'),
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
}
