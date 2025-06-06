import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_013 - Create community tanpa foto', () async {
    // setup cookie palsu
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'o-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh',
      'tt_cookie':
          's%3Ao-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh.8Ir8SPqIMST%2FiEpm%2FzPKS02bvtRyUL9pC0JMu1WZNAE',
    });

    try {
      final response = await ComumnityService.createCommunity(
        name: 'Unit Testing',
        description: 'Deskripsi komunitas untuk testing',
        imageFile: null,
      );

      if (response.statusCode == 201) {
        print('✅ TCU_013 - Komunitas berhasil dibuat');
      } else {
        print(
            '⚠️ TCU_013 - Gagal membuat komunitas: ${response.statusCode} | ${response.body}');
      }

      expect(response.statusCode, 201);
    } catch (e) {
      print('❌ TCU_013 - Error saat buat komunitas: $e');
      fail('Request error: $e');
    }
  });
}
