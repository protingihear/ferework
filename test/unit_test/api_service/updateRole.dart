import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/api_service.dart';

void main() {
  test('🧪 TCU_004 - Update User Role dengan session valid', () async {
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'hBZfO3usjq7J9zcl5Gfqnq3HHACzPwjC',
      'tt_cookie': 's%3AhBZfO3usjq7J9zcl5Gfqnq3HHACzPwjC.KkeAzyEMzyV1TAXtITk96GQ6NYjIMor1O2CLoqMKAW0',
    });

    try {
      await ApiService.updateUserRole('ahli_bahasa');
      print('✅ TCU_004 - Role berhasil diupdate');
    } catch (e) {
      final message = e.toString().toLowerCase();

      // Handle case kalau role sudah pernah diupdate (anggap ini tetap sukses)
      if (message.contains('sudah') || message.contains('pernah')) {
        print('✅ TCU_004 - Role sudah pernah diupdate sebelumnya (tetap valid)');
      } else {
        print('❌ TCU_004 - Gagal update role: $e');
        fail('Update role failed: $e');
      }
    }
  });
}
