import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

Future<void> initPrefs() async {
  prefs = await SharedPreferences.getInstance();
}

class AuthService {
  static const String _baseUrl = 'https://berework-production.up.railway.app';

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

      //cek value kiriman backend ke front-end
      print("🔍 Status Code: ${response.statusCode}");
      print("📜 Headers: ${response.headers}");
      print("📜 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final cookies = response.headers['set-cookie'];
        print("📢 Full Set-Cookie Header: $cookies");

        if (cookies != null) {
          // Ambil session_id dan tt dari cookies
          final prefs = await SharedPreferences.getInstance();

          final sessionMatch = RegExp(r'session_id=([^;]+)').firstMatch(cookies);
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

          //return sebagai akhir dari fungsi login ketika login berhasil
          return null; 
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
  Future<void> logout() async {
    await prefs.remove('session_cookie');
    await prefs.remove('tt_cookie');
    print("❌ Session dihapus dari local storage.");
  }
}
