import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/api_service.dart';

void main() {
  test('🧪 TCU_003 - Fetch User Profile dengan mock session & mock client',
      () async {
    // Mock data SharedPreferences
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'mock-session-id',
      'tt_cookie': 'mock-tt-id',
    });

    // Mock response dari server
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/profile') {
        return http.Response(
            jsonEncode({
              'id': 2,
              'email': 'mock@example.com',
              'firstname': 'Mock',
              'lastname': 'User',
              'gender': 'male',
            }),
            200);
      }
      return http.Response('Not Found', 404);
    });

    try {
      final profile = await ApiService.fetchUserProfile(client: mockClient);

      expect(profile, isNotNull);
      expect(profile.name, 'Mock User');
      print('✅ TCU_003 - Berhasil ambil profil mock: ${profile.name}');
    } catch (e) {
      print('❌ TCU_003 - Gagal ambil profil: $e');
      fail('Request error: $e');
    }
  });
}
