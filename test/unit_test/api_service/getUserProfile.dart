import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/api_service.dart';

void main() {
  test('🧪 TCU_003 - Fetch User Profile dengan session valid', () async {
    // Setup mock session cookies di SharedPreferences
    SharedPreferences.setMockInitialValues({
      'id': '2',
      'session_cookie': 'o-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh',
      'tt_cookie':
          's%3Ao-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh.8Ir8SPqIMST%2FiEpm%2FzPKS02bvtRyUL9pC0JMu1WZNAE',
    });

    try {
      final profile = await ApiService.fetchUserProfile();

      expect(profile, isNotNull);
    } catch (e) {
      print('❌ TCU_003 - Gagal ambil profil: $e');
      fail('Request error: $e');
    }
  });
}
