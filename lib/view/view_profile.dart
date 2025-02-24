// profile.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reworkmobile/models/user_profile.dart';
import 'package:reworkmobile/services/api_service.dart';
import 'package:reworkmobile/view/edit_profile.dart';
import 'sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfile> _profileFuture; // ✅ Ensures proper Future handling

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.fetchUserProfile(); // ✅ Directly fetch profile
  }

  void _updateProfile(UserProfile updatedProfile) {
    setState(() {
      _profileFuture = ApiService.fetchUserProfile(); // ✅ Refetch data from API
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading profile: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found'));
          }

          final profile = snapshot.data!;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(profile: profile, onUpdateProfile: _updateProfile),
                  const SizedBox(height: 15),
                  // AccountSettings(profile: profile),
                  const SizedBox(height: 8),
                  const FAQAndLogoutButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final Function(UserProfile) onUpdateProfile;

  const ProfileHeader(
      {Key? key, required this.profile, required this.onUpdateProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: profile.imageUrl.startsWith('data:image')
                ? Image.memory(base64Decode(profile.imageUrl.split(',')[1])).image
                : NetworkImage(profile.imageUrl),
            onBackgroundImageError: (_, __) => Icon(Icons.error),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.bio,
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gender: ${profile.gender}',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
  onPressed: () async {
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



                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Center(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FAQAndLogoutButtons extends StatelessWidget {
  const FAQAndLogoutButtons({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Remove userId from SharedPreferences

    // Navigate to the sign-in page and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Sign_In_Page()),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        ListTile(
          tileColor: Colors.green.shade100,
          leading: const Icon(Icons.help, color: Colors.green),
          title: const Text(
            'FAQ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () {
            // Add FAQ navigation logic here if needed
          },
        ),
        const SizedBox(height: 8),
        ListTile(
          tileColor: Colors.green.shade100,
          leading:
              const Icon(Icons.logout, color: Color.fromARGB(255, 239, 0, 0)),
          title: const Text(
            'Log Out',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 17, 0),
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () => _logout(context), // Call the logout function on tap
        ),
      ],
    );
  }
}

// class AccountSettings extends StatefulWidget {
//   final UserProfile profile;

//   const AccountSettings({Key? key, required this.profile}) : super(key: key);

//   @override
//   State<AccountSettings> createState() => _AccountSettingsState();
// }

// class _AccountSettingsState extends State<AccountSettings> {
//   bool _isExpanded = false;

//   void _navigateToEditEmailPassword() {
//     // Navigator.push(
//     //   // context,
//     //   // MaterialPageRoute(
//     //   //   builder: (context) => EditEmailPasswordPage(profile: widget.profile),
//     //   // ),
//     // );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(top: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.green.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Icon(Icons.settings, color: Colors.green),
//               const SizedBox(width: 8),
//               const Expanded(
//                 child: Text(
//                   'Pengaturan Akun',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(
//                   _isExpanded ? Icons.expand_less : Icons.expand_more,
//                   color: Colors.green,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _isExpanded = !_isExpanded;
//                   });
//                 },
//               ),
//             ],
//           ),
//           if (_isExpanded)
//             Column(
//               children: [
//                 for (var email in widget.profile.emails)
//                   Text(email, style: TextStyle(color: Colors.black)),
//                 const SizedBox(height: 8),
//                 ElevatedButton(
//                   onPressed: _navigateToEditEmailPassword,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: const Text('Edit Email & Password'),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }