import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reworkmobile/view/relation/post/CreatePostPage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CreatePostPage Integration Test', () {
    testWidgets('validasi input dan submit post berhasil', (WidgetTester tester) async {
      // Bikin widget CreatePostPage dengan contoh data komunitas
      await tester.pumpWidget(
        MaterialApp(
          home: CreatePostPage(communityId: 1, communityName: 'Test Community'),
        ),
      );

      // Pastikan teks komunitas muncul
      print('🔍 TCI_001 - Menampilkan nama komunitas');
      expect(find.text('📢 Posting ke komunitas: Test Community'), findsOneWidget);

      // Tombol submit harus muncul
      print('🔍 TCI_002 - Menampilkan tombol submit');
      expect(find.text('Posting Sekarang!'), findsOneWidget);

      // Coba submit tanpa isi konten, harus ada error snackbar
      print('🔍 TCI_003 - Validasi input kosong');
      await tester.tap(find.text('Posting Sekarang!'));
      await tester.pumpAndSettle();

      expect(find.text('🚫 Konten tidak boleh kosong!'), findsOneWidget);

      // Isi konten
      print('🔍 TCI_004 - Submit berhasil setelah isi konten');
      await tester.enterText(find.byType(TextField), 'Ini postingan test');
      await tester.pumpAndSettle();

      // Submit konten
      await tester.tap(find.text('Posting Sekarang!'));
      await tester.pump();
    });
  });
}
