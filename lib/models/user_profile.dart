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
    String firstname = json['firstname'] ?? '';
    String lastname = json['lastname'] ?? '';

    return UserProfile(
      id: json['id'].toString(),
      name: '$firstname $lastname'.trim(),
      bio: json['bio'] ?? '',
      imageUrl: _resolveImage(json['Image'] ?? json['picture']), // Check both keys
      emails: json['email'] != null ? [json['email']] : [],
      gender: json['gender'] ?? '',
    );
  }


  static String _resolveImage(dynamic image) {
    if (image == null || image.toString().isEmpty) {
      return 'https://via.placeholder.com/250';
    }

    String imageStr = image.toString();

    if (imageStr.startsWith('http')) {
      return imageStr; // Already a full URL
    }

    if (imageStr.length > 100) {
      return 'data:image/png;base64,$imageStr'; // Handle Base64 images
    }

    return '$baseUrl/storage/$imageStr'; // Ensure full path
  }

}
