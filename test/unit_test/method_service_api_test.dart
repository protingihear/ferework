import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:reworkmobile/services/method_service.dart';
import 'dart:convert';

class MockClient extends Mock implements http.Client {}

void main() {
  group('MethodService API Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('fetchCategories returns list of categories if successful', () async {
      final responseJson = jsonEncode([
        {'id': 1, 'name': 'Kategori 1'},
        {'id': 2, 'name': 'Kategori 2'}
      ]);

      // Mock response sukses dengan status 200
      when(mockClient.get(Uri.parse('${MethodService.baseUrl}/categories')))
          .thenAnswer((_) async => http.Response(responseJson, 200));

      // Kamu perlu buat versi testable yang menerima http.Client di MethodService agar bisa testing
      // Contoh: MethodService.fetchCategories(client: mockClient)

      // final categories = await MethodService.fetchCategories(client: mockClient);
      // expect(categories.length, 2);
      // expect(categories[0]['name'], 'Kategori 1');
    });
  });
}
