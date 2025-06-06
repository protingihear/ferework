import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_015 - Fetch Posts komunitas dari API asli', () async {
    const testCommunityId = 1;

    try {
      final posts = await ComumnityService.fetchCommunityPosts(testCommunityId);

      print('✅ TCU_015 - Berhasil ambil ${posts.length} post');
      expect(posts, isA<List<dynamic>>());
    } catch (e) {
      print('❌ TCU_015 - Gagal ambil posts: $e');
      fail('Failed to fetch community posts: $e');
    }
  });
}
