import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

void main() {
  test('🧪 TCU_017 - Kirim reply komentar di post komunitas (Mocked)',
      () async {
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'fake_session_cookie',
      'tt_cookie': 'fake_tt_cookie',
    });

    const int communityId = 1;
    const int postId = 1;
    const String content = 'Reply test dari unit test';
    const int? replyId = null;

    final mockClient = MockClient((http.Request request) async {
      print('📥 Request: ${request.method} ${request.url}');
      print('📦 Headers: ${request.headers}');
      print('📦 Body: ${request.body}');

      if (request.method == 'POST' && request.url.path.contains('/replies')) {
        final body = jsonDecode(request.body);
        if (body['content'] == content &&
            (replyId == null || body['replyId'] == replyId)) {
          return http.Response(jsonEncode({'message': 'Reply sent'}), 201);
        }
      }

      return http.Response(jsonEncode({'message': 'Unauthorized'}), 401);
    });

    try {
      await ComumnityService.sendReply(
        communityId: communityId,
        postId: postId,
        content: content,
        replyId: replyId,
        client: mockClient,
      );
      print('✅ TCU_017 - Reply berhasil dikirim (Mocked)');
    } catch (e) {
      print('❌ TCU_017 - Gagal kirim reply: $e');
      fail('Send reply failed: $e');
    }
  });
}
