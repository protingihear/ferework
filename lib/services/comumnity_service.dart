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

static Future<void> createPost(int communityId, String content) async {
  final url = Uri.parse('https://berework-production.up.railway.app/api/communities/$communityId/posts');

  try {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final ttCookie = prefs.getString('tt_cookie');

    if (sessionCookie == null || ttCookie == null) {
      throw Exception("❌ Gagal membuat post: Session tidak ditemukan. Harap login terlebih dahulu.");
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

    print("📤 Payload: ${jsonEncode({"communityId": communityId, "content": content})}");
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
 static Future<void> createCommunity(String name, String description, String imageBase64) async {
    final url = Uri.parse('$baseUrl/communities');

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      final ttCookie = prefs.getString('tt_cookie');

      if (sessionCookie == null || ttCookie == null) {
        throw Exception("❌ Gagal membuat komunitas: Session tidak ditemukan. Harap login terlebih dahulu.");
      }

      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Cookie": "session_id=$sessionCookie; tt=$ttCookie",
      };

      final Map<String, dynamic> body = {
        "name": name,
        "description": description,
        "foto": imageBase64, // Sesuai API backend
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print("📤 Payload: ${jsonEncode(body)}");
      print("📥 Response Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Komunitas berhasil dibuat!");
      } else {
        throw Exception("❌ Gagal membuat komunitas: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error saat membuat komunitas: $e");
      throw Exception("Terjadi kesalahan: $e");
    }
  }
}


