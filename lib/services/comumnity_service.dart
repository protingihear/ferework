import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/community.dart';

class ApiService {
  static Future<List<Community>> fetchCommunities() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/communities'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Community.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load communities');
    }
  }
}
