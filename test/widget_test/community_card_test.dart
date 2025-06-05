import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/models/community.dart';
import 'package:reworkmobile/widgets/community_card.dart';

void main() {
  group('CommunityCard Widget', () {
    final communityWithImage = Community(
      name: 'Komunitas Hijau',
      description: 'Deskripsi komunitas yang keren.',
      imageBase64: base64Encode(List.filled(10, 1)), 
      id: 1,
    );

    final communityWithoutImage = Community(
      name: 'Komunitas Kosong',
      description: 'Deskripsi tanpa gambar.',
      imageBase64: '', 
      id: 1,
    );

    testWidgets('menampilkan gambar base64 dan teks', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommunityCard(community: communityWithImage),
        ),
      );

      expect(find.text('Komunitas Hijau'), findsOneWidget);
      expect(find.text('Deskripsi komunitas yang keren.'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.image_not_supported), findsNothing);
    });

    testWidgets('menampilkan icon placeholder jika imageBase64 kosong', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommunityCard(community: communityWithoutImage),
        ),
      );

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
      expect(find.text('Komunitas Kosong'), findsOneWidget);
      expect(find.text('Deskripsi tanpa gambar.'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('menampilkan warna dan border sesuai isSelected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommunityCard(
            community: communityWithImage,
            isSelected: true,
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, Colors.green[100]);
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.color, Colors.green);
    });

    testWidgets('menampilkan warna default jika isSelected false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommunityCard(
            community: communityWithImage,
            isSelected: false,
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, Colors.grey[200]);
      expect(decoration.border, isNull);
    });
  });
}
