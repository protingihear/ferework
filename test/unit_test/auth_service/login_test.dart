import 'package:reworkmobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Inisialisasi SharedPreferences
  SharedPreferences.setMockInitialValues({});
  await initPrefs();

  final authService = AuthService();

  // 🔹 Test Case
  const testCaseCode = 'TCU_001';
  const testDescription = 'Login dengan kredensial valid';

  print("🧪 Test Case: $testCaseCode");
  print("📋 Deskripsi : $testDescription");
  print("🔐 Mulai login...");

  final result = await authService.login("Admin", "Admin123@");

  if (result == null) {
    print("✅ [$testCaseCode] Hasil: Login berhasil!");
  } else {
    print("❌ [$testCaseCode] Hasil: Login gagal - $result");
  }
}
