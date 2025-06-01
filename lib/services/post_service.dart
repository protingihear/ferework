import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/community.dart';
import '../models/post.dart';

class ApiService {
  static const String baseUrl =
      'http://74.226.193.115:5001/api';
      
  static Future<List<Community>> fetchCommunities() async {
    final response = await http.get(Uri.parse("$baseUrl/communities"));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Community.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load communities");
    }
  }

  static Future<List<Post>> fetchPosts(int communityId) async {
    final response = await http.get(Uri.parse("$baseUrl/communities/$communityId/posts"));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }
}