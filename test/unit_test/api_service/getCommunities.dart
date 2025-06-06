import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_011 - Fetch Communities dari API', () async {
    try {
      final communities = await ComumnityService.fetchCommunities();

      if (communities.isNotEmpty) {
        print('✅ TCU_011 - Berhasil ambil ${communities.length} komunitas');
      } else {
        print('✅ TCU_011 - Request berhasil, tapi belum ada komunitas');
      }

      expect(communities, isA<List>());
    } catch (e) {
      print('❌ TCU_011 - Gagal ambil komunitas: $e');
      fail('Request error: $e');
    }
  });
}
