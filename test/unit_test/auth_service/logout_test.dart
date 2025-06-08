import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reworkmobile/services/auth_service.dart';

void main() {
  test('🧪 TCU_0018 - Logout dengan session valid (Mocked)', () async {
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'dummy_session_id_123',
      'tt_cookie': 'dummy_tt_token_abc',
      'user_data': '{"id":1,"name":"Test User"}',
      'user_id': 1,
    });

    final mockClient = MockClient((request) async {
      if (request.url.path.endsWith('/api/logout') &&
          request.method == 'POST') {
        return http.Response('', 200);
      }
      return http.Response('Not Found', 404);
    });

    await AuthService.logout(client: mockClient);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('session_cookie'), isNull);
    expect(prefs.getString('tt_cookie'), isNull);
    expect(prefs.getString('user_data'), isNull);
    expect(prefs.getInt('user_id'), isNull);
  });
}
