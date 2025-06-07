import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reworkmobile/view/profile/view_profile.dart';
import 'package:reworkmobile/widgets/post_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration Test for ProfilePage UI and behavior',
      (WidgetTester tester) async {
    // Langsung set ProfilePage sebagai home
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    // Tunggu render pertama
    await tester.pumpAndSettle();

    // Buka halaman setting (SettingsPage)
    await tester.tap(find.text('Atur Profil 💼'));
    await tester.pumpAndSettle();

    // Cek navigasi ke SettingsPage (asumsi ada tombol Simpan misalnya)
    expect(find.text('Simpan'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Pindah ke tampilan chat
    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();

    // Harus ada search bar
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'tes');
    await tester.pumpAndSettle();

    // Coba klik "View More" jika ada
    final viewMoreFinder = find.text('View More');
    if (viewMoreFinder.evaluate().isNotEmpty) {
      await tester.tap(viewMoreFinder);
      await tester.pumpAndSettle();
    }

    // Balik ke tampilan post
    await tester.tap(find.byIcon(Icons.add_reaction_outlined));
    await tester.pumpAndSettle();

    // Kalau nggak ada post
    if (find.textContaining('Belum ada postingan').evaluate().isNotEmpty) {
      expect(find.text('📸 Bagi Aktifitas Kamu!'), findsOneWidget);
    } else {
      // Kalau ada post
      expect(find.byType(PostCard), findsWidgets);
    }
  });
}
