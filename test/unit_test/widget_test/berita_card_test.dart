import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/widgets/berita_card.dart';

void main() {
  group('BeritaCard Widget', () {
    final sampleBerita = {
      'judul': 'Judul Contoh Berita',
      'isi': 'Ini adalah isi dari berita yang sangat menarik dan panjang sekali. ' * 3,
      'foto': base64Encode(List.filled(10, 0)), // dummy base64
    };

    testWidgets('menampilkan judul dan isi berita', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeritaCard(
              berita: sampleBerita,
              onTap: () {},
            ),
          ),
        ),
      );

      // Cek judul muncul
      expect(find.text('Judul Contoh Berita'), findsOneWidget);

      // Cek deskripsi yang dipotong
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('memanggil callback saat diklik', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeritaCard(
              berita: sampleBerita,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BeritaCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('menampilkan icon jika foto null', (WidgetTester tester) async {
      final beritaTanpaFoto = {
        'judul': 'Berita Tanpa Gambar',
        'isi': 'Deskripsi singkat tanpa gambar',
        'foto': null,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeritaCard(
              berita: beritaTanpaFoto,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });
}
