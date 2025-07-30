import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('🧪 TCU_010 - Create SubCategory (Mocked)', () async {
    const baseUrl = 'http://20.2.209.127:3000/api';
    const categoryId = '1';
    const apiUrl = '$baseUrl/categories/$categoryId/subcategories';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    const video = 'https://video.test/video.mp4';

    final name = 'SubKategori Test $timestamp';
    const description = 'Deskripsi subkategori test';

    // Mock HTTP Client
    final mockClient = MockClient((http.Request request) async {

      if (request.method == 'POST' && request.url.toString() == apiUrl) {
        final body = jsonDecode(request.body);
        if (body['name'] == name &&
            body['video'] == video &&
            body['description'] == description &&
            body['done'] == false) {
          return http.Response(jsonEncode({'message': 'SubCategory created'}), 201);
        }
      }

      return http.Response(jsonEncode({'message': 'Bad Request'}), 400);
    });

    try {
      final response = await mockClient.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'video': video,
          'description': description,
          'done': false,
        }),
      );

      if (response.statusCode == 201) {
        print('✅ TCU_010 - SubKategori berhasil dibuat (Mocked)');
      } else {
        print('⚠️ TCU_010 - Gagal membuat SubKategori (Mocked): ${response.statusCode} | ${response.body}');
      }

      expect(response.statusCode, 201);
    } catch (e) {
      print('❌ TCU_010 - Error saat membuat SubKategori: $e');
      fail('Request error: $e');
    } finally {
      mockClient.close();
    }
  });
}
