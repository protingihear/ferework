import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/community.dart';
import '../models/post.dart';

class ApiService {
  static const String baseUrl = 'http://20.214.51.17:5001/api';

  static Future<List<Community>> fetchCommunities({http.Client? client}) async {
    client ??= http.Client();
    final response = await client.get(Uri.parse("$baseUrl/communities"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Community.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load communities");
    }
  }

  static Future<List<Post>> fetchPosts(int communityId, {http.Client? client}) async {
    client ??= http.Client();
    final response = await client.get(Uri.parse("$baseUrl/communities/$communityId/posts"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }
}
