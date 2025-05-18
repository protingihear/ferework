import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

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
    String? firstname,
    String? lastname,
    String? bio,
    String? gender,
    File? image, // File dari picker
    bool removeImage = false, // Kalau true, akan set Image jadi ""
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_cookie');
      final tt = prefs.getString('tt_cookie');

      print('--- DEBUG: Starting updateUserProfile ---');
      print('sessionId: $sessionId');
      print('tt: $tt');

      final uri = Uri.parse('$_baseUrl/api/profile');
      final request = http.MultipartRequest('PUT', uri);

      // Headers
      request.headers['Cookie'] = "session_id=$sessionId; tt=$tt";
      request.headers['Accept'] = 'application/json';

      print('Headers set: ${request.headers}');

      // Fields
      if (firstname != null) {
        request.fields['firstname'] = firstname;
        print('Field firstname: $firstname');
      }
      if (lastname != null) {
        request.fields['lastname'] = lastname;
        print('Field lastname: $lastname');
      }
      if (bio != null) {
        request.fields['bio'] = bio;
        print('Field bio: $bio');
      }
      if (gender != null) {
        request.fields['gender'] = gender;
        print('Field gender: $gender');
      }

      // Image file or remove flag
      if (image != null) {
        final multipartFile =
            await http.MultipartFile.fromPath('Image', image.path);
        request.files.add(multipartFile);
        print('Image file added: ${image.path}');
      } else if (removeImage) {
        request.fields['Image'] = "";
        print('Image removal requested');
      }

      print('Sending request to: $uri');
      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Parsed JSON response: $jsonResponse');
        return jsonResponse;
      } else {
        final errorResponse = jsonDecode(response.body);
        print('Error from server: $errorResponse');
        throw Exception(errorResponse['message'] ?? 'Gagal update user');
      }
    } catch (e) {
      print('Exception caught in updateUserProfile: $e');
      rethrow;
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
