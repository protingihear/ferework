import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

String baseUrl = 'http://10.0.2.2:5000';

class UserProfile {
  final String id;
  final String name;
  final String bio;
  String imageUrl;
  final List<String> emails;
  final String gender;

  UserProfile({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
    required this.emails,
    required this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      name: '${json['firstname'] ?? ''} ${json['lastname'] ?? ''}'.trim(),
      bio: json['bio'] ?? '',
      imageUrl: json['picture'] != null && json['picture'].toString().isNotEmpty
          ? (json['picture'].toString().startsWith('http')
              ? json['picture']
              : '$baseUrl${json['picture']}')
          : 'https://via.placeholder.com/250',
      emails: json['email'] != null ? [json['email']] : [],
      gender: json['gender'] ?? '',
    );
  }

  void updateImage(String newImageUrl) {
    imageUrl = newImageUrl;
  }
}
