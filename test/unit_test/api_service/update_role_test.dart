import 'package:reworkmobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SharedPreferences.setMockInitialValues({
    'session_cookie': 'o-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh',
    'tt_cookie': 's%3Ao-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh.8Ir8SPqIMST%2FiEpm%2FzPKS02bvtRyUL9pC0JMu1WZNAE',
  });

  print('🧪 TCU_004 - Update User Role dengan session valid');

  try {
    await ApiService.updateUserRole('ahli_bahasa');
    print('✅ TCU_004 - Role berhasil diupdate');
  } catch (e) {
    final message = e.toString().toLowerCase();
    if (message.contains('sudah') || message.contains('pernah')) {
      print('✅ TCU_004 - Role sudah pernah diupdate sebelumnya (tetap valid)');
    } else {
      print('❌ TCU_004 - Gagal update role: $e');
    }
  }
}
