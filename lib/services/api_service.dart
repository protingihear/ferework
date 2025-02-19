import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:5000';

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
      [String? password, String? imageUrl]) async {
    // Added `imageUrl`

    final url = Uri.parse('$_baseUrl/api/profile');

    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_cookie');
    final tt = prefs.getString('tt_cookie');

    if (sessionId == null || tt == null) {
      throw Exception("Session ID or tt not found");
    }

    final nameParts = name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final body = {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'bio': bio,
      'gender': gender == 'Perempuan' ? 'P' : 'L',
    };

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Add image if available
      body['picture'] = imageUrl;
    }

    print("Updating profile with:");
    print("URL: $url");
    print("Headers: ${{
      'Content-Type': 'application/json',
      "Cookie": "session_id=$sessionId; tt=$tt",
    }}");
    print("Body: ${json.encode(body)}");

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Cookie": "session_id=$sessionId; tt=$tt",
        },
        body: json.encode(body),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return UserProfile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print("Error updating profile: $e");
      throw Exception('Error updating profile: $e');
    }
  }
}
