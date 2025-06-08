import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_015 - Fetch Posts komunitas (Mocked)', () async {
    const testCommunityId = 1;

    final mockClient = MockClient((http.Request request) async {
      if (request.url.path == '/api/communities/$testCommunityId/posts') {
        return http.Response(
            jsonEncode({
              'posts': [
                {'id': 1, 'content': 'Mocked post 1'},
                {'id': 2, 'content': 'Mocked post 2'},
              ]
            }),
            200);
      }
      return http.Response('Not Found', 404);
    });

    try {
      final posts = await ComumnityService.fetchCommunityPosts(
        testCommunityId,
        client: mockClient,
      );

      print('✅ TCU_015 - Berhasil ambil ${posts.length} post (Mocked)');
      expect(posts, isA<List<dynamic>>());
      expect(posts.length, 2);
    } catch (e) {
      print('❌ TCU_015 - Gagal ambil posts: $e');
      fail('Failed to fetch community posts: $e');
    }
  });
}
