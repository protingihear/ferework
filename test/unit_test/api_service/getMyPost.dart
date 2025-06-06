import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_016 - Fetch My Posts dengan session valid', () async {
    // Mock cookie biar ada session valid
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'o-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh',
      'tt_cookie':
          's%3Ao-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh.8Ir8SPqIMST%2FiEpm%2FzPKS02bvtRyUL9pC0JMu1WZNAE',
    });

    try {
      final myPosts = await ComumnityService.fetchMyPosts();

      print('✅ TCU_016 - Berhasil ambil ${myPosts.length} post saya');
      expect(myPosts, isA<List<dynamic>>());
    } catch (e) {
      print('❌ TCU_016 - Gagal ambil post saya: $e');
      fail('Fetch my posts failed: $e');
    }
  });
}
