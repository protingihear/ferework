import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/services/method_service.dart';

void main() {
  testWidgets('showChoiceDialog displays dialog with two buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => MethodService.showChoiceDialog(context),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Jenis Tambah'), findsOneWidget);
    expect(find.text('Tambah Kategori'), findsOneWidget);
    expect(find.text('Tambah SubKategori'), findsOneWidget);
  });
}
