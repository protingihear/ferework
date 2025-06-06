import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/services/method_service.dart';

void main() {
  test('🧪 TCU_002 - Fetch kategori dari API asli', () async {
    final result = await MethodService.fetchCategories();

    if (result.isNotEmpty) {
      print('✅ TCU_002 - Berhasil ambil data kategori');
    } else {
      print('⚠️ FCU_002 - Gagal ambil data kategori (kosong atau error)');
    }

    expect(result.isNotEmpty, true);
  });
}
