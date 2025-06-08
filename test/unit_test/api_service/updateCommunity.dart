import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reworkmobile/services/comumnity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('🧪 TCU_008 editCommunity sukses dengan mock client', () async {
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'dummy_session_id_123',
      'tt_cookie': 'dummy_tt_token_abc',
    });

    final mockClient = MockClient((http.Request request) async {
      expect(request.method, 'PUT');
      expect(request.url.path, '/api/communities/42');
      expect(request.headers['Content-Type']?.startsWith('application/json'), isTrue);
      expect(request.headers['Cookie'], contains('dummy_session_id_123'));
      expect(request.headers['Cookie'], contains('dummy_tt_token_abc'));

      final body = jsonDecode(request.body);
      expect(body['name'], 'Nama Baru');
      expect(body['description'], 'Deskripsi Baru');

      return http.Response('', 200);
    });

    final result = await ComumnityService.editCommunity(
      communityId: 42,
      name: 'Nama Baru',
      description: 'Deskripsi Baru',
      client: mockClient,
    );

    expect(result, true);
    print("✅ TCU_008 - Community berhasil diupdate (mock)!");
  });
}
