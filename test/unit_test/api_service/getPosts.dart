import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test("🧪 TCU_0012 - Fetch Posts dari komunitas (Mocked)", () async {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/communities/1/posts') {
        return http.Response(jsonEncode({
          'posts': [
            {'id': 1, 'content': 'Post A'},
            {'id': 2, 'content': 'Post B'},
          ]
        }), 200);
      }
      return http.Response('Not Found', 404);
    });

    try {
      final posts = await ComumnityService.fetchPosts(1, client: mockClient);

      expect(posts, isNotNull);
      expect(posts.length, 2);
      print("✅ TCU_0012 - Fetch berhasil, total: ${posts.length} post(s)");
    } catch (e) {
      print("❌ TCU_0012 - Fetch gagal: $e");
      fail("Gagal ambil post: $e");
    }
  });
}
