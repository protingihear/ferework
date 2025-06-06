import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/auth_service.dart';

void main() {
  test('🧪 TCU_001 - Login dengan kredensial valid', () async {
    SharedPreferences.setMockInitialValues({}); // reset prefs
    await initPrefs();

    final authService = AuthService();

    final result = await authService.login("testing", "Admin123@");

    if (result == null) {
      print("✅ TCU_001 - Login berhasil!");
    } else {
      print("❌ TCU_001 - Login gagal - $result");
      fail("Login gagal: $result");
    }
  });
}
