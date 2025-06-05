import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/view/Relation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RelationsPage Integration Test', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({'user_id': 1});
    });

    testWidgets('Render UI and interact with community list',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RelationsPage()));

      // Tunggu build selesai
      await tester.pumpAndSettle();

      // Cek apakah judul "Relations" muncul
      expect(find.text('Relations'), findsOneWidget);

      // Cek apakah search bar muncul
      expect(find.byType(TextField), findsOneWidget);

      // Isi teks ke dalam search bar
      await tester.enterText(find.byType(TextField), 'komunitas');
      await tester.pumpAndSettle();

      // Coba cari kartu komunitas (CommunityCard)
      final communityCardFinder = find.byType(GestureDetector).first;

      if (communityCardFinder.evaluate().isNotEmpty) {
        // Tap community pertama jika ada
        await tester.tap(communityCardFinder);
        await tester.pumpAndSettle();

        // Cek tombol "Buat Post" muncul
        expect(find.text('Buat Post'), findsOneWidget);
      } else {
        // Kalau tidak ada komunitas, pastikan text ini muncul
        expect(find.text('Tidak ada komunitas ditemukan'), findsOneWidget);
      }

      // Scroll ke bawah untuk melihat "Belum ada postingan" atau spinner
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Cek tombol FAB "Add"
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      // Tap tombol Add
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      // Setelah navigasi ke AddCommunityPage, kita kembali saja agar test tetap jalan
      await tester.pageBack();
      await tester.pumpAndSettle();
    });
  });
}
