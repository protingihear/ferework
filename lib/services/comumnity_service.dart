import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/community.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComumnityService {
  static const String baseUrl = 'http://20.214.51.17:5001/api';

  static Future<List<Community>> fetchCommunities({http.Client? client}) async {
    client ??= http.Client();

    final response = await client.get(Uri.parse('$baseUrl/communities'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Community.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load communities');
    }
  }

  static Future<List<dynamic>> fetchPosts(int communityId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/communities/$communityId/posts"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['posts'];
      return data;
    } else {
      throw Exception("Failed to load posts");
    }
  }

  static Future<List<dynamic>> fetchCommunityPosts(int communityId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/communities/$communityId/posts'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['posts'];
      // print(data);
      return data;
    } else {
      throw Exception('Failed to load community posts');
    }
  }

  static Future<http.Response> createPost(
    int communityId,
    String content, {
    http.Client? client,
  }) async {
    client ??= http.Client();

    final url = Uri.parse('$baseUrl/communities/$communityId/posts');

    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final ttCookie = prefs.getString('tt_cookie');

    if (sessionCookie == null || ttCookie == null) {
      throw Exception(
          "❌ Gagal membuat post: Session tidak ditemukan. Harap login terlebih dahulu.");
    }

    final response = await client.post(
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

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Gagal membuat post: ${response.body}");
    }

    return response;
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

      // print("🔍 Status Code: ${response.statusCode}");
      // print("📜 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // print("✅ Berhasil join komunitas!");
      } else {
        throw Exception("❌ Gagal join komunitas: ${response.body}");
      }
    } catch (e) {
      // print("⚠️ Error saat join komunitas: $e");
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  // Fungsi untuk keluar dari komunitas
  static Future<String> leaveCommunity(int communityId) async {
    final url = Uri.parse('$baseUrl/communities/$communityId/leave');
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final ttCookie = prefs.getString('tt_cookie');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': "session_id=$sessionCookie; tt=$ttCookie",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message'];
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal keluar dari komunitas');
    }
  }

  // Fungsi mengambil komunitas yang telah diikuti
  static Future<List<dynamic>> getJoinedCommunities() async {
    final url = Uri.parse('$baseUrl/communities/joined');
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final ttCookie = prefs.getString('tt_cookie');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': "session_id=$sessionCookie; tt=$ttCookie",
      },
    );

    // print("Status code: ${response.statusCode}");
    // print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print("Joined Communities Response: $data");
      return data['joinedCommunities'];
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal mengambil data komunitas');
    }
  }

  static Future<http.Response> createCommunity({
    required String name,
    required String description,
    File? imageFile,
    http.Client? client,
  }) async {
    client ??= http.Client();
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
      ..headers['Cookie'] = "session_id=$sessionId; tt=$tt";

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

    final streamedResponse = await client.send(request); // <-- DI SINI
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  static Future<bool> editCommunity({
    required int communityId,
    required String name,
    required String description,
  }) async {
    final url = Uri.parse('$baseUrl/communities/$communityId');
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final ttCookie = prefs.getString('tt_cookie');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionCookie; tt=$ttCookie',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // print("Gagal update komunitas: ${response.body}");
      return false;
    }
  }

  static Future<List<dynamic>> getCommunityMembers({
    required int communityId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/communities/$communityId/members');
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final ttCookie = prefs.getString('tt_cookie');

    final response = await http.get(
      url,
      headers: {
        'Cookie': 'session_id=$sessionCookie; tt=$ttCookie',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['members'];
    } else {
      // print('Gagal mengambil anggota komunitas: ${response.body}');
      return [];
    }
  }

  static Future<List<dynamic>> getLikedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('cookie');

      if (cookie == null) {
        throw Exception('Silakan login terlebih dahulu');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/communities/posts/liked'),
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
      // print('Error getting liked posts: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchMyPosts() async {
    final url = Uri.parse('$baseUrl/posts/mine');

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_cookie');
      final tt = prefs.getString('tt_cookie');

      if (sessionId == null || tt == null) {
        throw Exception("Session ID or tt not found");
      }
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': "session_id=$sessionId; tt=$tt",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['posts'];
      } else {
        throw Exception('Gagal memuat data post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<void> likeContent({
    required String communityId,
    required String postId,
    String? replyId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_cookie');
    final tt = prefs.getString('tt_cookie');

    if (sessionId == null || tt == null) {
      throw Exception("Session ID or tt not found");
    }

    final uri = Uri.parse(
      '$baseUrl/communities/$communityId/posts/$postId/likes${replyId != null ? '?replyId=$replyId' : ''}',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId; tt=$tt',
      },
    );

    if (response.statusCode == 200) {
      // print("Liked successfully");
    } else {
      // print("Failed to like: ${response.statusCode} ${response.body}");
      throw Exception("Failed to like content");
    }
  }

  static Future<void> unlikeContent({
    required String communityId,
    required String postId,
    String? replyId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_cookie');
    final tt = prefs.getString('tt_cookie');

    if (sessionId == null || tt == null) {
      throw Exception("Session ID or tt not found");
    }

    final uri = Uri.parse(
      '$baseUrl/communities/$communityId/posts/$postId/likes${replyId != null ? '?replyId=$replyId' : ''}',
    );

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId; tt=$tt',
      },
    );

    if (response.statusCode == 200) {
      // print("Unliked successfully");
    } else if (response.statusCode == 404) {
      // print("Like tidak ditemukan");
    } else {
      // print("Gagal unlike: ${response.statusCode} ${response.body}");
      throw Exception("Failed to unlike content");
    }
  }

  static Future<void> sendReply({
    required int communityId,
    required int postId,
    required String content,
    int? replyId, // opsional
    http.Client? client,
  }) async {
    client ??= http.Client();

    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_cookie');
    final tt = prefs.getString('tt_cookie');

    if (sessionId == null || tt == null) {
      throw Exception("Session ID or tt not found");
    }

    final url = Uri.parse(
      "$baseUrl/communities/$communityId/posts/$postId/replies",
    );

    final response = await client.post(
      url,
      headers: {
        'Cookie': 'session_id=$sessionId; tt=$tt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        if (replyId != null) 'replyId': replyId,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Gagal mengirim komentar: ${response.body}");
    }
  }

  static Future<void> deleteCommunity(int communityId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_cookie');
    final tt = prefs.getString('tt_cookie');

    if (sessionId == null || tt == null) {
      throw Exception("Session ID or tt not found");
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/communities/$communityId'),
      headers: {
        'Cookie': 'session_id=$sessionId; tt=$tt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete community: ${response.body}');
    }
  }
}
