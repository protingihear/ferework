import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reworkmobile/services/berita_service.dart';
import 'package:path/path.dart' as p;

void main() {
  test('🧪 TCU_009 - updateBerita berhasil dengan mock client', () async {
    final mockClient = MockClient((http.Request request) async {
      // Validasi method dan URL
      expect(request.method, equals('PUT'));
      expect(request.url.path, contains('/api/berita/123'));

      return http.Response('OK', 200);
    });

    final tempDir = Directory.systemTemp;
    final dummyFile = await File(p.join(tempDir.path, 'dummy.jpg')).writeAsBytes([0, 1, 2]);

    await BeritaService.updateBerita(
      id: 123,
      judul: 'Judul Tes',
      isi: 'Isi Tes',
      tanggal: '2025-06-08',
      fotoFile: dummyFile,
      client: mockClient,
    );

    print("✅ TCU_0019 - updateBerita berhasil dijalankan (mock).");
  });
}
