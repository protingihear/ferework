import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class ApiService {
  static const String _baseUrl =
      'https://berework-production-ad0a.up.railway.app';

  static Future<UserProfile> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_cookie');
      final tt = prefs.getString('tt_cookie');

      if (sessionId == null || tt == null) {
        throw Exception("Session ID or tt not found");
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile'),
        headers: {
          "Content-Type": "application/json",
          "Cookie": "session_id=$sessionId; tt=$tt",
        },
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            "Failed to load profile, status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching profile: $e");
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required String firstname,
    required String lastname,
    String? bio,
    required String gender,
    Uint8List? imageBytes,
    String? sessionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final ttCookie = prefs.getString('tt_cookie');

    if (sessionCookie == null || ttCookie == null) {
      throw Exception(
          "❌ Gagal membuat post: Session tidak ditemukan. Harap login terlebih dahulu.");
    }
    final url = Uri.parse('$_baseUrl/api/profile');

    final request = http.MultipartRequest('PUT', url);

    request.headers['Cookie'] = "session_id=$sessionCookie; tt=$ttCookie";

    request.fields['firstname'] = firstname;
    request.fields['lastname'] = lastname;
    request.fields['gender'] = gender;

    if (bio != null) request.fields['bio'] = bio;

    if (imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'Image',
        imageBytes,
        filename: 'profile.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    } else {
      request.fields['Image'] = '';
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(resBody);
    } else {
      throw Exception('Failed to update profile: $resBody');
    }
  }

  static Future<List<dynamic>> fetchBerita() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/api/berita"));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Error fetching berita: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch berita: $e");
    }
  }
}
