import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_011 - Fetch Communities dari API (Mocked)', () async {
    final mockClient = MockClient((http.Request request) async {
      if (request.url.path.endsWith('/communities')) {
        return http.Response(
            jsonEncode([
              {'id': 1, 'name': 'Komunitas Test 1'},
              {'id': 2, 'name': 'Komunitas Test 2'}
            ]),
            200);
      }
      return http.Response('Not Found', 404);
    });

    try {
      final communities =
          await ComumnityService.fetchCommunities(client: mockClient);

      if (communities.isNotEmpty) {
        print(
            '✅ TCU_011 - Berhasil ambil ${communities.length} komunitas (Mocked)');
      } else {
        print(
            '✅ TCU_011 - Request berhasil, tapi belum ada komunitas (Mocked)');
      }

      expect(communities, isA<List>());
      expect(communities.length, greaterThan(0));
    } catch (e) {
      print('❌ TCU_011 - Gagal ambil komunitas (Mocked): $e');
      fail('Request error: $e');
    }
  });
}
