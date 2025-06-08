import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:reworkmobile/services/berita_service.dart';

void main() {
  test('🧪 TCU_005 Upload berita sukses mock dengan MockClient', () async {
    final mockClient = MockClient((http.Request request) async {
      // Cek endpoint dan method
      if (request.url.path == '/api/berita' && request.method == 'POST') {
        return http.Response('', 201);
      }
      return http.Response('Not found', 404);
    });

    final result = await BeritaService.uploadBerita(
      judul: 'Test Judul',
      isi: 'Test isi',
      tanggal: DateTime.now(),
      foto: null,
      client: mockClient,
    );

    expect(result, true);
    print("✅ TCU_005 Upload berita sukses mock dengan MockClient ${result}");
  });
}
