import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reworkmobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 ProfilePage Integration Test', () {
    testWidgets('Loads and displays user profile info and switches tabs', (WidgetTester tester) async {
      app.main();
      await tester.pump();

      final spinnerFinder = find.byType(CircularProgressIndicator);

      if (spinnerFinder.evaluate().isNotEmpty) {
        expect(spinnerFinder, findsWidgets);
        // Tunggu loading selesai
        await tester.pumpAndSettle(const Duration(seconds: 5));
      } else {
        print('Spinner loading tidak ditemukan, lanjut ke pengecekan UI');
        // Jika spinner tidak ada, beri waktu UI stabil
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Cek username dengan emoji 😎
      expect(find.textContaining('😎'), findsOneWidget);

      // Cek stats
      expect(find.text('Post'), findsOneWidget);
      expect(find.text('Teman'), findsOneWidget);
      expect(find.text('Fans'), findsOneWidget);

      // Tap tombol "Atur Profil 💼"
      final settingsButton = find.widgetWithText(OutlinedButton, 'Atur Profil 💼');
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Kembali ke profil
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Switch ke tab Chat
      final chatButton = find.byIcon(Icons.chat_bubble_outline);
      expect(chatButton, findsOneWidget);
      await tester.tap(chatButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cek ada search bar dan list tile di chat
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);

      // Switch kembali ke tab Post
      final postButton = find.byIcon(Icons.add_reaction_outlined);
      expect(postButton, findsOneWidget);
      await tester.tap(postButton);
      await tester.pumpAndSettle();

      // Cek header post community
      expect(find.textContaining('Aktivitas Postingan Community'), findsOneWidget);
    });
  });
}
