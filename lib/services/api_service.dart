import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ApiService {
  static const String _baseUrl = 'https://berework-production-ad0a.up.railway.app';

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

  static Future<UserProfile> updateUserProfile(
      String id, String name, String bio, String gender, String email,
      [String? password, File? imageFile, bool removeImage = false]) async {
    final url = Uri.parse('$_baseUrl/api/profile');

    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_cookie');
    final tt = prefs.getString('tt_cookie');

    if (sessionId == null || tt == null) {
      throw Exception("Session ID or tt not found");
    }

    final request = http.MultipartRequest('PUT', url);

    request.headers.addAll({
      "Cookie": "session_id=$sessionId; tt=$tt",
    });

    // Tambahkan form fields yang diperlukan
    request.fields['firstname'] = name.split(' ').first;
    request.fields['lastname'] =
        name.contains(' ') ? name.split(' ').sublist(1).join(' ') : '';
    request.fields['email'] = email;
    request.fields['bio'] = bio;
    request.fields['gender'] = gender; // Kirim langsung tanpa konversi

    if (password != null && password.isNotEmpty) {
      if (password.length < 6)
        throw Exception("Password must be at least 6 characters long");
      request.fields['password'] = password;
    }

    // ✅ Send "" to remove image
    if (imageFile != null) {
    request.files
          .add(await http.MultipartFile.fromPath('Image', imageFile.path));
    } else if (removeImage) {
      // ✅ Only remove if explicitly requested
      request.fields['Image'] = "";
    }

    // Kirim request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update profile: ${response.body}');
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
