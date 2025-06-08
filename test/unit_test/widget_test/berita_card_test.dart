// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:reworkmobile/widgets/berita_card.dart';

// void main() {
//   group('BeritaCard Widget', () {
//     const validBase64 =
//         'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=';

//     final sampleBerita = {
//       'judul': 'Judul Contoh Berita',
//       'isi': 'Ini adalah isi dari berita yang sangat menarik dan panjang sekali. ' * 3,
//       'foto': validBase64,
//     };

//     testWidgets('menampilkan judul dan isi berita', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: BeritaCard(
//               berita: sampleBerita,
//               onTap: () {},
//             ),
//           ),
//         ),
//       );

//       expect(find.text('Judul Contoh Berita'), findsOneWidget);
//       expect(find.byType(Text), findsWidgets);
//     });

//     testWidgets('memanggil callback saat diklik', (WidgetTester tester) async {
//       bool tapped = false;

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: BeritaCard(
//               berita: sampleBerita,
//               onTap: () {
//                 tapped = true;
//               },
//             ),
//           ),
//         ),
//       );

//       // Pakai GestureDetector untuk tap
//       await tester.tap(find.byType(GestureDetector));
//       await tester.pump();

//       expect(tapped, isTrue);
//     });

//     testWidgets('menampilkan icon jika foto null atau kosong', (WidgetTester tester) async {
//       final beritaTanpaFoto = {
//         'judul': 'Berita Tanpa Gambar',
//         'isi': 'Deskripsi singkat tanpa gambar',
//         'foto': '',  // coba juga test dengan '' kalau error
//       };

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: BeritaCard(
//               berita: beritaTanpaFoto,
//               onTap: () {},
//             ),
//           ),
//         ),
//       );

//       expect(find.byIcon(Icons.image_outlined), findsOneWidget);
//       expect(find.byType(Image), findsNothing);
//     });
//   });
// }
