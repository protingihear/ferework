import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/services/api_service.dart';

void main() {
  test('🧪 TCU_006 - Fetch daftar berita dari API', () async {
    try {
      final beritaList = await ApiService.fetchBerita();

      if (beritaList.isNotEmpty) {
        print('✅ TCU_006 - Berhasil ambil ${beritaList.length} berita');
      } else {
        print('✅ TCU_006 - Tidak ada berita, tapi request berhasil');
      }

      expect(beritaList, isA<List>());
    } catch (e) {
      print('❌ TCU_006 - Gagal ambil berita: $e');
      fail('Request error: $e');
    }
  });
}
