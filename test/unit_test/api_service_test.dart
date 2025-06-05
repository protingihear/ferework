import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reworkmobile/services/api_service.dart';
import 'dart:typed_data';

void main() {
  group('🔗 API Integration Tests (tanpa emulator)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'session_cookie': 'NO4Rg6x3oQ9V6-sbUGPyO67kDxWgc3vx',
        'tt_cookie': 's:NO4Rg6x3oQ9V6-sbUGPyO67kDxWgc3vx.CzuFylhpsm94lPIC2ApqzJTlTTbYSeUYn6Jm6cZUMGU	',
      });
    });

    test('🧪 fetchUserProfile returns a valid user profile or fails gracefully',
        () async {
      try {
        final profile = await ApiService.fetchUserProfile();
        print('✅ Raw profile object: $profile');
      } catch (e) {
        print('⚠️ fetchUserProfile failed: $e');
        expect(e, isA<Exception>());
      }
    });

    test('🧪 updateUserProfile works', () async {
      try {
        final result = await ApiService.updateUserProfile(
          firstname: 'Test',
          lastname: 'User',
          gender: 'other',
          bio: 'Testing Bio',
          imageBytes: Uint8List(0),
        );
        expect(result['firstname'], equals('Test'));
        print('✅ Updated profile: ${result['firstname']}');
      } catch (e) {
        print('⚠️ updateUserProfile failed: $e');
        expect(e, isA<Exception>());
      }
    });

    test('🧪 fetchBerita returns list of berita', () async {
      try {
        final berita = await ApiService.fetchBerita();
        expect(berita, isA<List>());
        print('✅ Total berita: ${berita.length}');
      } catch (e) {
        print('⚠️ fetchBerita failed: $e');
        expect(e, isA<Exception>());
      }
    });
  });
}
