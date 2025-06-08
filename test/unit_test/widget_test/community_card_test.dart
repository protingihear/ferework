import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/models/community.dart';
import 'package:reworkmobile/widgets/community_card.dart';

void main() {
  group('CommunityCard Widget', () {
    const validBase64Image =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=';

    final communityWithImage = Community(
      name: 'Komunitas Hijau',
      description: 'Deskripsi komunitas yang keren.',
      imageBase64: validBase64Image,
      id: 1,
      creatorId: 1,
    );

    final communityWithoutImage = Community(
      name: 'Komunitas Kosong',
      description: 'Deskripsi tanpa gambar.',
      imageBase64: '',
      id: 2,
      creatorId: 1,
    );

    testWidgets('Menampilkan gambar base64 dan teks',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommunityCard(community: communityWithImage, currentUserId: 1),
        ),
      ));

      expect(find.text('Komunitas Hijau'), findsOneWidget);
      expect(find.text('Deskripsi komunitas yang keren.'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.image_not_supported), findsNothing);
    });

    testWidgets('Menampilkan icon placeholder jika imageBase64 kosong',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body:
              CommunityCard(community: communityWithoutImage, currentUserId: 1),
        ),
      ));

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
      expect(find.text('Komunitas Kosong'), findsOneWidget);
      expect(find.text('Deskripsi tanpa gambar.'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('Menampilkan warna dan border jika isSelected true',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommunityCard(
            community: communityWithImage,
            isSelected: true,
            currentUserId: 1,
          ),
        ),
      ));

      // Ambil Container yang punya warna hijau dan border
      final container = tester.widget<Container>(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.green[100]),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.color, Colors.green);
    });

    testWidgets('Menampilkan warna default jika isSelected false',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommunityCard(
            community: communityWithImage,
            isSelected: false,
            currentUserId: 1,
          ),
        ),
      ));

      final container = tester.widget<Container>(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.grey[200]),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNull);
    });
  });
}
