import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/comumnity_service.dart';

/// 🔧 Tambahkan di SINI (sebelum main())
class MockMultipartClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request) handler;

  MockMultipartClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return handler(request);
  }
}

void main() {
  test('🧪 TCU_013 - Create community tanpa foto (Mocked)', () async {
    SharedPreferences.setMockInitialValues({
      'session_cookie': 'fake_session_cookie',
      'tt_cookie': 'fake_tt_cookie',
    });

    final mockClient = MockMultipartClient((http.BaseRequest request) async {
      final multipart = request as http.MultipartRequest;

      print('📥 Request: ${request.method} ${request.url}');
      print('📦 Headers: ${request.headers}');
      print('📦 Fields: ${multipart.fields}');

      final isAuth = request.headers['Cookie']?.contains('session_id=fake_session_cookie') == true &&
          request.headers['Cookie']?.contains('tt=fake_tt_cookie') == true;

      if (request.method == 'POST' &&
          request.url.path.contains('/communities') &&
          isAuth &&
          multipart.fields['name'] == 'Unit Testing' &&
          multipart.fields['description'] == 'Deskripsi komunitas untuk testing') {
        final body = utf8.encode(jsonEncode({'message': 'Community created'}));
        return http.StreamedResponse(Stream.value(body), 201);
      }

      final body = utf8.encode(jsonEncode({'message': 'Unauthorized'}));
      return http.StreamedResponse(Stream.value(body), 401);
    });

    try {
      final response = await ComumnityService.createCommunity(
        name: 'Unit Testing',
        description: 'Deskripsi komunitas untuk testing',
        imageFile: null,
        client: mockClient,
      );

      if (response.statusCode == 201) {
        print('✅ TCU_013 - Komunitas berhasil dibuat (Mocked)');
      } else {
        print('⚠️ TCU_013 - Gagal membuat komunitas (Mocked): ${response.statusCode} | ${response.body}');
      }

      expect(response.statusCode, 201);
    } catch (e) {
      print('❌ TCU_013 - Error saat buat komunitas: $e');
      fail('Request error: $e');
    }
  });
}
