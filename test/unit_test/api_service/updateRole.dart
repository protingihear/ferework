import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:reworkmobile/services/api_service.dart';

void main() {
  test('🧪 TCU_004 - Update User Role dengan mock client', () async {
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'mock-session-id',
      'tt_cookie': 'mock-tt-id',
    });

    final mockClient = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/api/profile') {
        final body = jsonDecode(request.body);
        if (body['role'] == 'ahli_bahasa') {
          return http.Response('', 200);
        }
        return http.Response(
            jsonEncode({'message': 'Role sudah pernah diupdate'}), 400);
      }
      return http.Response('Not Found', 404);
    });

    try {
      await ApiService.updateUserRole(
        'ahli_bahasa',
        client: mockClient,
      );
      print('✅ TCU_004 - Role berhasil diupdate (mock)');
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('sudah') || message.contains('pernah')) {
        print('✅ TCU_004 - Role sudah pernah diupdate sebelumnya (mock valid)');
      } else {
        print('❌ TCU_004 - Gagal update role (mock): $e');
        fail('Update role gagal: $e');
      }
    }
  });
}
