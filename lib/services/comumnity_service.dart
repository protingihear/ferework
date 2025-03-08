import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/community.dart';
import '../models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
   static const String baseUrl = 'https://berework-production.up.railway.app/api';

  static Future<List<Community>> fetchCommunities() async {
    final response = await http.get(Uri.parse('https://berework-production.up.railway.app/api/communities'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body); 
      return data.map((json) => Community.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load communities');
    }
  }


  static Future<List<Post>> fetchPosts(int communityId) async {
    final response = await http.get(Uri.parse("https://berework-production.up.railway.app/api/communities/$communityId/posts"));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }
static Future<List<dynamic>> fetchCommunityPosts(int communityId) async {
    final response = await http.get(Uri.parse('$baseUrl/communities/$communityId/posts'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['posts']; // Ambil array `posts`
      return data;
    } else {
      throw Exception('Failed to load community posts');
    }
  }
  static Future<Post> createPost(int communityId, String author, String content) async {
  // Pastikan user sudah join komunitas sebelum membuat post
  await http.post(Uri.parse('$baseUrl/communities/$communityId/join'));

  final response = await http.post(
    Uri.parse('$baseUrl/communities/$communityId/posts'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"author": author, "content": content}),
  );

  if (response.statusCode == 201) {

    return Post.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Gagal membuat post");
  }
}
  static Future<void> joinCommunity(int communityId) async {
    final url = Uri.parse('$baseUrl/communities/$communityId/join');

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      final ttCookie = prefs.getString('tt_cookie'); 

      if (sessionCookie == null || ttCookie == null) {
        throw Exception("❌ Gagal join: Session tidak ditemukan. Harap login terlebih dahulu.");
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

}
