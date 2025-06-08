import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_016 - Fetch My Posts dengan session valid (Mocked)', () async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'mock-session-id',
      'tt_cookie': 'mock-tt-cookie',
    });

    // Mock HTTP client
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/posts/mine') {
        return http.Response(jsonEncode({
          'posts': [
            {'id': 1, 'content': 'Mock Post A'},
            {'id': 2, 'content': 'Mock Post B'},
          ]
        }), 200);
      }
      return http.Response('Not Found', 404);
    });

    try {
      final myPosts = await ComumnityService.fetchMyPosts(client: mockClient);

      print('✅ TCU_016 - Berhasil ambil ${myPosts.length} post saya');
      expect(myPosts, isA<List<dynamic>>());
    } catch (e) {
      print('❌ TCU_016 - Gagal ambil post saya: $e');
      fail('Fetch my posts failed: $e');
    }
  });
}
