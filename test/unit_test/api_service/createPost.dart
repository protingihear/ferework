import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_014 - Create Post di komunitas dengan session valid (Mocked)',
      () async {
    // Setup mock cookie
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'fake_session_cookie',
      'tt_cookie': 'fake_tt_cookie',
    });

    const int testCommunityId = 1;
    const String testContent = 'Ini konten post test dari unit test';

    // Mock HTTP Client
    final mockClient = MockClient((http.Request request) async {
      print('📥 Request: ${request.method} ${request.url}');
      print('📦 Headers: ${request.headers}');
      print('📦 Body: ${request.body}');

      if (request.method == 'POST' && request.url.path.contains('/posts')) {
        final body = jsonDecode(request.body);
        if (body['communityId'] == testCommunityId &&
            body['content'] == testContent) {
          return http.Response(jsonEncode({'message': 'Post created'}), 201);
        }
      }

      return http.Response(jsonEncode({'message': 'Unauthorized'}), 401);
    });

    try {
      final response = await ComumnityService.createPost(
        testCommunityId,
        testContent,
        client: mockClient, // <-- inject mock client
      );

      if (response.statusCode == 201) {
        print('✅ TCU_014 - Post berhasil dibuat (Mocked)');
      } else {
        print(
            '⚠️ TCU_014 - Gagal membuat post (Mocked): ${response.statusCode} | ${response.body}');
      }

      expect(response.statusCode, 201);
    } catch (e) {
      print('❌ TCU_014 - Gagal membuat post: $e');
      fail('Create post failed: $e');
    }
  });
}
