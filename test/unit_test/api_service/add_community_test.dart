import 'package:reworkmobile/services/comumnity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Mock SharedPreferences session cookies
  SharedPreferences.setMockInitialValues({
    'session_cookie': 'o-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh',
    'tt_cookie': 's%3Ao-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh.8Ir8SPqIMST%2FiEpm%2FzPKS02bvtRyUL9pC0JMu1WZNAE',
  });

  print('🧪 TCU_013 - Create Community tanpa foto');

  try {
    final response = await ComumnityService.createCommunity(
      name: 'Komunitas Test',
      description: 'Deskripsi komunitas untuk testing',
      imageFile: null,
    );

    if (response.statusCode == 201) {
      print('✅ TCU_013 - Komunitas berhasil dibuat');
    } else {
      print('⚠️ TCU_013 - Gagal membuat komunitas: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ TCU_013 - Error saat buat komunitas: $e');
  }
}
