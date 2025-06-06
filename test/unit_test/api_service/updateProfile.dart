import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/api_service.dart';

void main() {
  test('🧪 TCU_007 - Update User Profile dengan data valid', () async {
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'o-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh',
      'tt_cookie': 's%3Ao-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh.8Ir8SPqIMST%2FiEpm%2FzPKS02bvtRyUL9pC0JMu1WZNAE',
    });

    print("🔄 Update profil dimulai...");

    try {
      final response = await ApiService.updateUserProfile(
        firstname: 'Test unit',
        lastname: 'User',
        bio: 'Ini bio test',
        gender: 'Laki-laki',
        imageBytes: null,
      );

      print('✅ TCU_007 - Profil berhasil diupdate!');
      print('📦 Respon: $response');

    } catch (e) {
      print('❌ TCU_007 - Gagal update profil: $e');
      fail("Update profil gagal: $e");
    }
  });
}
