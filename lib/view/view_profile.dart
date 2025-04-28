// profile.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:reworkmobile/models/user_profile.dart';
import 'package:reworkmobile/services/api_service.dart';
import 'package:reworkmobile/view/edit_profile.dart';
import 'package:reworkmobile/view/view_setting.dart';
import 'sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfile> _profileFuture;
  List<dynamic> users = [];
  String currentView = 'add'; // default view = add
  bool isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.fetchUserProfile();
  }

  void _updateProfile(UserProfile updatedProfile) {
    setState(() {
      _profileFuture = ApiService.fetchUserProfile();
    });
  }

  Future<void> fetchUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_cookie');
      final tt = prefs.getString('tt_cookie');

      if (sessionId == null || tt == null) {
        throw Exception("Session ID or tt not found");
      }

      final response = await http.get(
        Uri.parse('https://berework-production-ad0a.up.railway.app/api/users'),
        headers: {
          "Content-Type": "application/json",
          "Cookie": "session_id=$sessionId; tt=$tt",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
        });
      } else {
        throw Exception("Failed to load users, status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentView == 'add') {
      // tampil tulisan "bagi aktifitas kamu"
    } else if (currentView == 'chat') {
      // tampil ListView semua user
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading profile: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found'));
          }

          final profile = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              profile.imageUrl.startsWith('data:image')
                                  ? Image.memory(base64Decode(
                                          profile.imageUrl.split(',')[1]))
                                      .image
                                  : NetworkImage(profile.imageUrl),
                          onBackgroundImageError: (_, __) =>
                              const Icon(Icons.error),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Post', '0'),
                              _buildStatColumn('Following', '0'),
                              _buildStatColumn('Followers', '0'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${profile.bio}"',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingsPage(
                                        profile: profile,
                                        onUpdateProfile: _updateProfile),
                                  ));
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            child: const Text('Pengaturan',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            currentView = 'add';
                          });
                        },
                        icon: const Icon(Icons.add_box_outlined),
                        iconSize: 32,
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            isLoadingUsers = true;
                          });

                          await fetchUsers();

                          setState(() {
                            currentView = 'chat';
                            isLoadingUsers = false;
                          });
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        iconSize: 32,
                      ),
                    ],
                  ),
        
                  const Divider(thickness: 1),
                  
                  if (currentView == 'add') ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: const [
                          Text(
                            'Bagi Aktifitas Kamu',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Saat anda membagikan postingan,\nakan muncul di aktivitas anda',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ] else if (currentView == 'chat') ...[
                    if (isLoadingUsers) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ] else ...[
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // biar gak nabrak scroll utama
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(user['imageUrl'] ?? ''),
                            ),
                            title: Text(
                                user['firstname'] + " " + user['lastname'] ??
                                    'Unknown'),
                            subtitle: Text(user['bio'] ?? ''),
                            onTap: () {
                              // aksi kalau klik user
                            },
                          );
                        },
                      ),
                    ]
                  ],
                  
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String title, String count) {
    return GestureDetector(
      onTap: () {
        if (title == 'Post') {
          print('post ditekan');
        } else if (title == 'Following') {
          print('following ditekan');
        } else if (title == 'Followers') {
          print('followers ditekan');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
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