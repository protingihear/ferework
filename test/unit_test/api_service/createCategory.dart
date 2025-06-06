import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('🧪 TCU_009 - Create kategori baru ke API asli', () async {
    const baseUrl = 'http://20.214.51.17:5001/api';
    const apiUrl = '$baseUrl/categories';

    // Tambahin timestamp biar gak duplikat terus
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testCategoryName = 'Kategori Test $timestamp';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': testCategoryName}),
      );

      if (response.statusCode == 201) {
        print('✅ TCU_009 - Kategori berhasil dibuat');
      } else {
        print(
            '⚠️ TCU_009 - Gagal buat kategori: ${response.statusCode} | ${response.body}');
      }

      expect(response.statusCode, 201);
    } catch (e) {
      print('❌ TCU_009 - Error saat request: $e');
      fail('Request error: $e');
    }
  });
}
