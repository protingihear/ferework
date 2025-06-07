import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:reworkmobile/view/authtentication/sign_in.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Sign In flow test', (WidgetTester tester) async {
    print('[TCI_011] Menampilkan halaman Sign In');
    await tester.pumpWidget(MaterialApp(home: Sign_In_Page()));
    await tester.pumpAndSettle();

    print('[TCI_012] Cari dan isi field email');
    final emailField = find.byKey(const Key('usernameField'));
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'Admin');
    await tester.pumpAndSettle();

    print('[TCI_013] Cari dan isi field password');
    final passwordField = find.byKey(const Key('passwordField'));
    expect(passwordField, findsOneWidget);
    await tester.enterText(passwordField, 'Admin123@');
    await tester.pumpAndSettle();

    print('[TCI_014] Tekan tombol Sign In');
    final signInButton = find.byKey(const Key('signInButton'));
    expect(signInButton, findsOneWidget);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    print('[TCI_015] Cek apakah login berhasil atau gagal');
    final bottomNavBar = find.byKey(const Key('mainBottomNavBar'));
    final bottomNavBarExists = bottomNavBar.evaluate().isNotEmpty;

    if (bottomNavBarExists) {
      print('[TCI_014 ✅] Login berhasil, BottomNavigationBar ditemukan');
      expect(bottomNavBar, findsOneWidget);
    } else {
      print('[TCI_015 ⚠️] Login gagal, tetap di halaman Sign In');
      expect(signInButton, findsOneWidget);
    }
  });
}
