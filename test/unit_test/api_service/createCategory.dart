import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('🧪 TCU_009 - Create kategori baru (Mocked)', () async {
    const testCategoryName = 'Kategori Test Mocked';

    // Simulasi response dari server
    final mockClient = MockClient((http.Request request) async {
      if (request.url.toString() == 'http://20.2.209.127:3000/api/categories' &&
          request.method == 'POST' &&
          request.headers['Content-Type']?.startsWith('application/json') ==
              true) {
        final body = jsonDecode(request.body);
        print('🔍 Body name: ${body['name']}');

        if (body['name'] == 'Kategori Test Mocked') {
          return http.Response(
            jsonEncode({'message': 'Kategori berhasil dibuat'}),
            201,
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      return http.Response('Invalid request', 400);
    });

    // Kirim request ke mockClient
    final response = await mockClient.post(
      Uri.parse('http://20.2.209.127:3000/api/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': testCategoryName}),
    );

    if (response.statusCode == 201) {
      print('✅ TCU_009 - Kategori berhasil dibuat (Mocked)');
    } else {
      print(
          '⚠️ TCU_009 - Gagal buat kategori (Mocked): ${response.statusCode} | ${response.body}');
    }

    expect(response.statusCode, 201);
  });
}
