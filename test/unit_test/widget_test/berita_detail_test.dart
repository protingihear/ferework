import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/widgets/berita_detail.dart';

void main() {
  group('BeritaDetail Widget', () {
    const validBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=';

    final sampleBerita = {
      'judul': 'Berita Detail Judul',
      'isi': 'Ini adalah isi lengkap dari berita yang panjang.',
      'foto': validBase64,
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
        'foto': null, // atau bisa juga coba dengan ''
      };

      await tester.pumpWidget(
        MaterialApp(
          home: BeritaDetail(berita: beritaTanpaFoto),
        ),
      );

      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.byType(Image), findsNothing);
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

      expect(find.byType(BeritaDetail), findsNothing);
    });
  });
}
