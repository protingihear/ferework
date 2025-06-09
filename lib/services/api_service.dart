import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ApiService {
  static const String _baseUrl = 'http://20.214.51.17:5001';

  static Future<UserProfile> fetchUserProfile({http.Client? client}) async {
    client ??= http.Client();
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_cookie');
      final tt = prefs.getString('tt_cookie');

      if (sessionId == null || tt == null) {
        throw Exception("Session ID or tt not found");
      }

      final response = await client.get(
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
    String? base64Image,
    http.Client? client,
  }) async {
    client ??= http.Client();

    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final ttCookie = prefs.getString('tt_cookie');

    if (sessionCookie == null || ttCookie == null) {
      throw Exception("❌ Gagal update: Session tidak ditemukan. Harap login.");
    }

    final uri = Uri.parse('$_baseUrl/api/profile');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Cookie'] = 'session_id=$sessionCookie; tt=$ttCookie'
      ..fields['firstname'] = firstname
      ..fields['lastname'] = lastname
      ..fields['gender'] = gender
      ..fields['bio'] = bio ?? '';

    if (base64Image != null && base64Image.isNotEmpty) {
      final bytes = base64Decode(base64Image);
      request.files.add(http.MultipartFile.fromBytes(
        'Image',
        bytes,
        filename: 'profile.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    if (base64Image != null && base64Image.isEmpty) {
      request.fields['Image'] = "";
    }

    try {
      // pakai client.send() untuk MultipartRequest
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('✅ Profil berhasil diupdate: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print('❌ Gagal update profil: ${response.body}');
        throw Exception('Gagal update profil: ${response.body}');
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat update profil: $e");
    } finally {
      client.close();
    }
  }

  static Future<void> updateUserRole(String newRole,
      {http.Client? client}) async {
    client ??= http.Client();

    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final ttCookie = prefs.getString('tt_cookie');

    if (sessionCookie == null || ttCookie == null) {
      throw Exception(
          "❌ Gagal mengubah role: Session tidak ditemukan. Harap login terlebih dahulu.");
    }

    final url = Uri.parse('$_baseUrl/api/profile');
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'session_id=$sessionCookie; tt=$ttCookie',
    };

    final body = jsonEncode({'role': newRole});

    try {
      final response = await client.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("✅ Role updated successfully!");
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] ?? 'Request tidak valid';

        if (message.toLowerCase().contains("sudah") ||
            message.toLowerCase().contains("pernah")) {
          throw Exception("⚠️ Kode sudah pernah digunakan.");
        }

        throw Exception(
            "Gagal update role: Redeem Code sudah pernah digunakan");
      } else {
        throw Exception(
            "Gagal update role. Server mengembalikan status ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat mengubah role: $e");
    } finally {
      client.close();
    }
  }

  static Future<List<dynamic>> fetchBerita({http.Client? client}) async {
    client ??= http.Client();

    try {
      final response = await client.get(Uri.parse("$_baseUrl/api/berita"));

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
