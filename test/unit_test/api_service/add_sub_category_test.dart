import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 TCU_010 - Create SubCategory');

  const baseUrl = 'http://20.214.51.17:5001/api';
  const categoryId = '1';
  const apiUrl = '$baseUrl/categories/$categoryId/subcategories';

  const name = 'SubKategori Test';
  const video = 'https://video.test/video.mp4';
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
      print('⚠️ TCU_010 - Gagal membuat SubKategori: ${response.body}');
    }
  } catch (e) {
    print('❌ TCU_010 - Error saat membuat SubKategori: $e');
  } finally {
    client.close();
  }
}
