import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_014 - Create Post di komunitas dengan session valid', () async {
    // Setup mock cookie di SharedPreferences
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'o-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh',
      'tt_cookie':
          's%3Ao-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh.8Ir8SPqIMST%2FiEpm%2FzPKS02bvtRyUL9pC0JMu1WZNAE',
    });

    const int testCommunityId = 1; // sesuaikan dengan komunitas yang valid
    const String testContent = 'Ini konten post test dari unit test';

    try {
      await ComumnityService.createPost(testCommunityId, testContent);
      print('✅ TCU_014 - Post berhasil dibuat');
    } catch (e) {
      print('❌ TCU_014 - Gagal membuat post: $e');
      fail('Create post failed: $e');
    }
  });
}
