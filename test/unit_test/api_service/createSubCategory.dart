import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('🧪 TCU_010 - Create SubCategory', () async {
    const baseUrl = 'http://20.214.51.17:5001/api';
    const categoryId = '1';
    const apiUrl = '$baseUrl/categories/$categoryId/subcategories';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    const video = 'https://video.test/video.mp4';

    final name = 'SubKategori Test $timestamp';
    const description = 'Deskripsi subkategori test';

    final client = http.Client();

    try {
      final response = await client.post(
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
        print('✅ TCU_010 - SubKategori berhasil dibuat');
      } else {
        print('⚠️ TCU_010 - Gagal membuat SubKategori: ${response.statusCode} | ${response.body}');
      }

      expect(response.statusCode, 201);
    } catch (e) {
      print('❌ TCU_010 - Error saat membuat SubKategori: $e');
      fail('Request error: $e');
    } finally {
      client.close();
    }
  });
}
