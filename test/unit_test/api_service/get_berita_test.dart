import 'package:reworkmobile/services/api_service.dart';

void main() async {
  print('🧪 TCU_008 - Fetch daftar berita');

  try {
    final beritaList = await ApiService.fetchBerita();

    if (beritaList.isNotEmpty) {
      print('✅ TCU_008 - Berhasil ambil ${beritaList.length} berita');
    } else {
      print('✅ TCU_008 - Tidak ada berita, tapi request berhasil');
    }
  } catch (e) {
    print('❌ TCU_008 - Gagal ambil berita: $e');
  }
}
