import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reworkmobile/services/comumnity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('🧪 TCU_011 - deleteCommunity sukses dengan mock client', () async {
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'dummy_session_id',
      'tt_cookie': 'dummy_tt_token',
    });

    final mockClient = MockClient((http.Request request) async {
      expect(request.method, 'DELETE');
      expect(request.url.path, '/api/communities/123');
      expect(request.headers['Cookie'], contains('dummy_session_id'));
      expect(request.headers['Cookie'], contains('dummy_tt_token'));
      expect(request.headers['Content-Type'], 'application/json');
      return http.Response('', 200);
    });

    await ComumnityService.deleteCommunity(123, client: mockClient);
    print("✅ TCU_011 - Community berhasil dihapus (mock).");
  });
}
