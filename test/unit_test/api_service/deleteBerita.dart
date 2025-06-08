import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reworkmobile/services/berita_service.dart';

void main() {
  test('🧪 TCU_010 - deleteBerita berhasil dengan mock client', () async {
    final mockClient = MockClient((http.Request request) async {
      expect(request.method, equals('DELETE'));
      expect(request.url.path, contains('/api/berita/99'));
      return http.Response('', 200);
    });

    await BeritaService.deleteBerita(99, client: mockClient);

    print('✅ TCU_020 - deleteBerita berhasil dijalankan (mock).');
  });
}
