import 'package:reworkmobile/services/comumnity_service.dart';

void main() async {
  print('🧪 TCU_012 - Fetch Posts dari komunitas');

  const testCommunityId = 1; // ganti sesuai data valid di servermu

  try {
    final posts = await ComumnityService.fetchPosts(testCommunityId);

    if (posts.isNotEmpty) {
      print('✅ TCU_012 - Berhasil ambil ${posts.length} post');
    } else {
      print('✅ TCU_012 - Request berhasil, tapi tidak ada post');
    }
  } catch (e) {
    print('❌ TCU_012 - Gagal ambil post: $e');
  }
}
