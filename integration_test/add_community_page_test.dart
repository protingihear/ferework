import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reworkmobile/view/AddCommunityPage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AddCommunityPage form submission test', (WidgetTester tester) async {
    print('=== START TEST: AddCommunityPage form submission test ===');

    // [TCI_005] Buka halaman AddCommunityPage
    print('[TCI_005] Membuka halaman AddCommunityPage');
    await tester.pumpWidget(
      MaterialApp(
        home: AddCommunityPage(),
      ),
    );
    await tester.pumpAndSettle();

    // [TCI_006] Isi nama komunitas
    print('[TCI_006] Mengisi field "Nama Komunitas"');
    final nameField = find.byType(TextFormField).at(0);
    await tester.enterText(nameField, 'Komunitas Test');

    // [TCI_007] Isi deskripsi komunitas
    print('[TCI_007] Mengisi field "Deskripsi"');
    final descField = find.byType(TextFormField).at(1);
    await tester.enterText(descField, 'Ini deskripsi komunitas test.');

    // [TCI_008] Klik area pilih gambar
    print('[TCI_008] Menekan area "Klik untuk pilih gambar"');
    final imagePickerArea = find.text('Klik untuk pilih gambar');
    expect(imagePickerArea, findsOneWidget);
    await tester.tap(imagePickerArea);
    await tester.pumpAndSettle();
    print('[TCI_008] Pemilihan gambar dilewati karena tidak dapat diuji tanpa mocking');

    // [TCI_009] Klik tombol "Buat Komunitas"
    print('[TCI_009] Menekan tombol "Buat Komunitas"');
    final submitButton = find.byKey(const Key('submitCommunity'));
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // [TCI_010] Verifikasi munculnya SnackBar
    print('[TCI_010] Memverifikasi apakah SnackBar muncul');
    expect(find.byType(SnackBar), findsOneWidget);
    print('[TCI_010] SUCCESS: SnackBar muncul, form berhasil diproses (baik berhasil/gagal)');

    print('=== END TEST: AddCommunityPage form submission test ===');
  });
}
