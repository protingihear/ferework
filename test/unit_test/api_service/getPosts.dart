import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test("🧪 TCU_0012 - Fetch Posts dari komunitas", () async {
    try {
      final posts = await ComumnityService.fetchPosts(1);

      expect(posts, isNotNull);
      print("✅ TCU_0012 - Fetch berhasil, total: ${posts.length} post(s)");
    } catch (e) {
      print("❌ TCU_0012 - Fetch gagal: $e");
      fail("Gagal ambil post: $e");
    }
  });
}
