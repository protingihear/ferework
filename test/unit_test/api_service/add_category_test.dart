import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 TCU_009 - Create kategori baru');

  const String baseUrl = 'http://20.214.51.17:5001/api';
  const String testCategoryName = 'Kategori Test';

  final String apiUrl = '$baseUrl/categories';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': testCategoryName}),
    );

    if (response.statusCode == 201) {
      print('✅ TCU_009 - Kategori berhasil dibuat');
    } else {
      print('⚠️ TCU_009 - Gagal membuat kategori: ${response.body}');
    }
  } catch (e) {
    print('❌ TCU_009 - Terjadi kesalahan saat membuat kategori: $e');
  }
}
