import 'package:reworkmobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Simulasi cookie yang valid
  SharedPreferences.setMockInitialValues({
    'id': '2',
    'session_cookie': 'o-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh',
    'tt_cookie':
        's%3Ao-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh.8Ir8SPqIMST%2FiEpm%2FzPKS02bvtRyUL9pC0JMu1WZNAE',
  });

  print('🧪 TCU_003 - Fetch User Profile dengan session valid');

  try {
    final profile = await ApiService.fetchUserProfile();
    // ignore: unnecessary_null_comparison
    if (profile != null) {
      print('✅ TCU_003 - Profil berhasil diambil:');
    }
  } catch (e) {
    print('❌ TCU_003 - Gagal ambil profil: $e');
  }
}
