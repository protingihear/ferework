import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/community.dart';

class ApiService {
  static const String baseUrl = 'https://berework-production.up.railway.app/api';

  // Ambil daftar komunitas
  static Future<List<Community>> fetchCommunities() async {
    final response = await http.get(Uri.parse('$baseUrl/communities'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['communities']; 
      return data.map((json) => Community.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load communities');
    }
  }

  // Ambil daftar postingan berdasarkan ID komunitas
  static Future<List<dynamic>> fetchCommunityPosts(int communityId) async {
    final response = await http.get(Uri.parse('$baseUrl/communities/$communityId/posts'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['posts']; // Ambil array `posts`
      return data;
    } else {
      throw Exception('Failed to load community posts');
    }
  }
}
