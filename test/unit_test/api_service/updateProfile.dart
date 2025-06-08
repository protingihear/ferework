import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reworkmobile/services/api_service.dart';

void main() {
  test('🧪 TCU_007 - Update User Profile dengan mock client', () async {
    // Mock SharedPreferences session cookies
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'mock-session-id',
      'tt_cookie': 'mock-tt-id',
    });

    // MockClient yang merespon MultipartRequest POST ke /api/profile
    final mockClient = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/api/profile') {
        // Contoh response sukses update profile
        return http.Response(
            jsonEncode({'success': true, 'message': 'Profile updated'}), 200);
      }
      return http.Response('Not Found', 404);
    });

    try {
      final response = await ApiService.updateUserProfile(
        firstname: 'Test unit',
        lastname: 'User',
        bio: 'Ini bio test',
        gender: 'Laki-laki',
        base64Image: null,
        client: mockClient,
      );

      expect(response['success'], true);
      expect(response['message'], 'Profile updated');
      print('✅ TCU_007 - Profil berhasil diupdate (mock)!');
    } catch (e) {
      print('❌ TCU_007 - Gagal update profil (mock): $e');
      fail('Update profil gagal: $e');
    }
  });
}
