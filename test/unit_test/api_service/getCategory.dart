import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:reworkmobile/services/method_service.dart';

void main() {
  test('🧪 TCU_002 - Fetch kategori dengan mock client', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/categories') {
        return http.Response(
            jsonEncode([
              {'id': 1, 'name': 'Kategori Test 1'},
              {'id': 2, 'name': 'Kategori Test 2'}
            ]),
            200);
      }
      return http.Response('Not Found', 404);
    });

    final result = await MethodService.fetchCategories(client: mockClient);

    expect(result.isNotEmpty, true);
    expect(result[0]['name'], 'Kategori Test 1');
    print('✅ TCU_002 - Fetch kategori berhasil dengan mock');
  });
}
