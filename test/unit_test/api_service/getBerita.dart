import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reworkmobile/services/api_service.dart';

void main() {
  test('🧪 TCU_006 - Fetch daftar berita dari API (Mocked)', () async {
    final mockBerita = [
      {
        'id': 1,
        'title': 'Berita Test 1',
        'content': 'Isi berita test 1',
      },
      {
        'id': 2,
        'title': 'Berita Test 2',
        'content': 'Isi berita test 2',
      },
    ];

    final mockClient = MockClient((http.Request request) async {
      print('📥 Mocked request: ${request.url}');
      return http.Response(jsonEncode(mockBerita), 200);
    });

    try {
      final beritaList = await ApiService.fetchBerita(client: mockClient);

      if (beritaList.isNotEmpty) {
        print(
            '✅ TCU_006 - Berhasil ambil ${beritaList.length} berita (Mocked)');
      } else {
        print('✅ TCU_006 - Tidak ada berita, tapi request berhasil (Mocked)');
      }

      expect(beritaList, isA<List>());
      expect(beritaList.length, mockBerita.length);
    } catch (e) {
      print('❌ TCU_006 - Gagal ambil berita (Mocked): $e');
      fail('Request error: $e');
    }
  });
}
