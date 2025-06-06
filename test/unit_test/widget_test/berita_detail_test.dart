import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/widgets/berita_detail.dart';

void main() {
  group('BeritaDetail Widget', () {
    final sampleBerita = {
      'judul': 'Berita Detail Judul',
      'isi': 'Ini adalah isi lengkap dari berita yang panjang.',
      'foto': base64Encode(List.filled(10, 0)), // dummy base64
    };

    testWidgets('menampilkan judul, isi, dan gambar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BeritaDetail(berita: sampleBerita),
        ),
      );

      expect(find.text('Berita Detail Judul'), findsOneWidget);
      expect(find.text('Ini adalah isi lengkap dari berita yang panjang.'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('menampilkan icon placeholder jika foto null', (WidgetTester tester) async {
      final beritaTanpaFoto = {
        'judul': 'Tanpa Gambar',
        'isi': 'Isi berita tanpa gambar.',
        'foto': null,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: BeritaDetail(berita: beritaTanpaFoto),
        ),
      );

      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('tombol close menutup halaman', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => BeritaDetail(berita: sampleBerita),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Karena setelah pop, tidak ada lagi BeritaDetail
      expect(find.byType(BeritaDetail), findsNothing);
    });
  });
}
