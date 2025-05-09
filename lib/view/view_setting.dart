import 'package:flutter/material.dart';
import 'package:reworkmobile/models/user_profile.dart';
import 'package:reworkmobile/services/auth_service.dart';
import 'package:reworkmobile/view/animation/splash_screen.dart';
import 'package:reworkmobile/view/edit_profile.dart';
import 'package:reworkmobile/view/view_verificationAhliBahasa.dart';

class SettingsPage extends StatelessWidget {
  final UserProfile profile;
  final Function(UserProfile) onUpdateProfile;

  const SettingsPage(
      {Key? key, required this.profile, required this.onUpdateProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2, // buat efek timbul default
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final updatedProfile = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(profile: profile),
                    ),
                  );
                  if (updatedProfile != null && updatedProfile is UserProfile) {
                    onUpdateProfile(updatedProfile);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.green),
                      SizedBox(width: 16),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.help_outline, color: Colors.green),
                title: Text(
                  'FAQ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  // Tambahkan navigasi FAQ
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.verified_user, color: Colors.green),
                title: Text(
                  'Upgrade Role',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SignLanguageExpertFormPage(),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  await AuthService.logout();
                  // Setelah logout, navigate ke halaman login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SplashScreen()), // <-- Diubah ke HomeScreen
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
