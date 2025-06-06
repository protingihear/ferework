import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('🧪 TCU_0018 - Logout dengan session valid', () async {
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'hBZfO3usjq7J9zcl5Gfqnq3HHACzPwjC',
      'tt_cookie': 's%3AhBZfO3usjq7J9zcl5Gfqnq3HHACzPwjC.KkeAzyEMzyV1TAXtITk96GQ6NYjIMor1O2CLoqMKAW0',
    });

    try {
      await AuthService.logout();
      print('✅ TCU_0018 - Logout function dipanggil dengan session valid.');
    } catch (e) {
      print('❌ TCU_0018 - Logout gagal: $e');
      fail('Logout gagal: $e');
    }
  });
}
