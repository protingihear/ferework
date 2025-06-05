import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:reworkmobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Buat mock client manual (atau bisa generate dengan mockito build_runner)
class MockClient extends Mock implements http.Client {}

late SharedPreferences prefs;

Future<void> initPrefs() async {
  prefs = await SharedPreferences.getInstance();
}

void main() {
  late MockClient mockClient;
  late AuthService authService;

  setUp(() async {
    // Setup mock shared preferences dengan nilai kosong
    SharedPreferences.setMockInitialValues({});
    await initPrefs();

    // Setup mock client
    mockClient = MockClient();

    // Buat instance AuthService dengan mock client
    authService = AuthService(client: mockClient);
  });

  group('AuthService Tests', () {
    test('hasSessionCookie returns true if cookie stored', () async {
      await prefs.setString('session_cookie', 'abc123');
      final result = await authService.hasSessionCookie();
      expect(result, true);
    });

    test('hasSessionCookie returns false if no cookie', () async {
      final result = await authService.hasSessionCookie();
      expect(result, false);
    });

    test('login returns null if success and stores cookies', () async {
      final responseHeaders = {
        'set-cookie': 'session_id=abc123; tt=tt456;',
        'content-type': 'application/json'
      };
      final responseBody = jsonEncode({
        'user': {
          'id': 1,
          'name': 'Test User',
        }
      });

      // Stub post request
      when(mockClient.post(
        Uri.parse('${AuthService.baseUrl}/auth/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200, headers: responseHeaders));

      final result = await authService.login('email@test.com', 'password');

      // login sukses, return null
      expect(result, null);

      // Pastikan session_cookie disimpan di prefs
      final savedSession = prefs.getString('session_cookie');
      expect(savedSession, 'abc123');

      // Pastikan tt_cookie juga disimpan
      final savedTt = prefs.getString('tt_cookie');
      expect(savedTt, 'tt456');
    });

    test('login returns error message if failed login', () async {
      final responseBody = jsonEncode({'message': 'Invalid credentials'});

      when(mockClient.post(
        Uri.parse('${AuthService.baseUrl}/auth/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 401));

      final result = await authService.login('email@test.com', 'wrongpass');

      expect(result, contains('Login gagal'));
    });
  });
}
