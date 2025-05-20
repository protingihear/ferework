import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/community.dart';
import '../models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComumnityService {
  static const String baseUrl =
      'https://berework-production-ad0a.up.railway.app/api';

  static Future<List<Community>> fetchCommunities() async {
    final response = await http.get(Uri.parse(
        'https://berework-production-ad0a.up.railway.app/api/communities'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print(data);
      return data.map((json) => Community.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load communities');
    }
  }

  static Future<List<Post>> fetchPosts(int communityId) async {
    final response = await http.get(Uri.parse(
        "https://berework-production-ad0a.up.railway.app/api/communities/$communityId/posts"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }

  static Future<List<dynamic>> fetchCommunityPosts(int communityId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/communities/$communityId/posts'));

    if (response.statusCode == 200) {
      List<dynamic> data =
          jsonDecode(response.body)['posts']; // Ambil array `posts`
      print(data);
      return data;
    } else {
      throw Exception('Failed to load community posts');
    }
  }

  static Future<void> createPost(int communityId, String content) async {
    final url = Uri.parse(
        'https://berework-production-ad0a.up.railway.app/api/communities/$communityId/posts');

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      final ttCookie = prefs.getString('tt_cookie');

      if (sessionCookie == null || ttCookie == null) {
        throw Exception(
            "❌ Gagal membuat post: Session tidak ditemukan. Harap login terlebih dahulu.");
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Cookie": "session_id=$sessionCookie; tt=$ttCookie",
        },
        body: jsonEncode({
          "communityId": communityId,
          "content": content,
        }),
      );

      print("📤 Payload: ${jsonEncode({
            "communityId": communityId,
            "content": content
          })}");
      print("📥 Response Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Post berhasil dibuat!");
      } else {
        throw Exception("Gagal membuat post: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Terjadi kesalahan: $e");
      throw Exception("Terjadi kesalahan saat membuat post: $e");
    }
  }

  static Future<void> joinCommunity(int communityId) async {
    final url = Uri.parse('$baseUrl/communities/$communityId/join');

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      final ttCookie = prefs.getString('tt_cookie');

      if (sessionCookie == null || ttCookie == null) {
        throw Exception(
            "❌ Gagal join: Session tidak ditemukan. Harap login terlebih dahulu.");
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Cookie": "session_id=$sessionCookie; tt=$ttCookie",
        },
      );

      print("🔍 Status Code: ${response.statusCode}");
      print("📜 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Berhasil join komunitas!");
      } else {
        throw Exception("❌ Gagal join komunitas: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error saat join komunitas: $e");
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  static Future<http.Response> createCommunity({
    required String name,
    required String description,
    File? imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/communities');

    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_cookie');
    final tt = prefs.getString('tt_cookie');

    if (sessionId == null || tt == null) {
      throw Exception("Session ID or tt not found");
    }

    final request = http.MultipartRequest('POST', uri)
      ..fields['name'] = name
      ..fields['description'] = description
      ..headers['Cookie'] =
          "session_id=$sessionId; tt=$tt"; // atau sesuaikan nama cookie session kamu

    // Tambah foto jika ada
    if (imageFile != null) {
      final imageBytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'foto',
          imageBytes,
          filename: imageFile.path.split('/').last,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      print('✅ Komunitas berhasil dibuat');
    } else {
      print('❌ Gagal membuat komunitas: ${response.statusCode}');
      print(response.body);
    }

    return response;
  }

  static Future<List<dynamic>> getLikedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('cookie');

      if (cookie == null) {
        throw Exception('Silakan login terlebih dahulu');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/communities/posts/liked'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': cookie,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> posts = data['posts'];
        return posts;
      } else if (response.statusCode == 401) {
        throw Exception('Silakan login terlebih dahulu');
      } else {
        throw Exception('Gagal mengambil data: ${response.body}');
      }
    } catch (e) {
      print('Error getting liked posts: $e');
      rethrow;
    }
  }
}
