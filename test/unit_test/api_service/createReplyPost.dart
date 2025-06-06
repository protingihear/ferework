import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_017 - Kirim reply komentar di post komunitas', () async {
    // Setup cookie mock
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'o-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh',
      'tt_cookie':
          's%3Ao-a8B2UG_aRskMjwZMBFP-J3HCyxpdOh.8Ir8SPqIMST%2FiEpm%2FzPKS02bvtRyUL9pC0JMu1WZNAE',
    });

    const int communityId = 1;
    const int postId = 1;
    const String content = 'Reply test dari unit test';
    const int? replyId = null;

    try {
      await ComumnityService.sendReply(
        communityId: communityId,
        postId: postId,
        content: content,
        replyId: replyId,
      );
      print('✅ TCU_017 - Reply berhasil dikirim');
    } catch (e) {
      print('❌ TCU_017 - Gagal kirim reply: $e');
      fail('Send reply failed: $e');
    }
  });
}
