import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:reworkmobile/models/user_profile.dart';
import 'package:reworkmobile/services/api_service.dart';
import 'package:reworkmobile/services/comumnity_service.dart';
import 'package:reworkmobile/view/profile/chat/chat_view.dart';
import 'package:reworkmobile/view/profile/profile_setting/view_setting.dart';
import 'package:reworkmobile/widgets/post_card.dart';
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
  String currentView = 'add';
  bool isLoadingUsers = false;

  List<dynamic> myPosts = [];
  int myPostsCount = 0;
  bool isLoadingMyPosts = false;
  bool hasFetchedMyPosts = false;

  int itemsToShow = 10;
  String searchQuery = '';

  late List<bool> isLikedList;

  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.fetchUserProfile();
    loadMyPosts();
    loadUserId();
  }

  void loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('user_id');
    });
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
        Uri.parse('http://20.214.51.17:5001/api/users'),
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

  Future<void> loadMyPosts() async {
    setState(() {
      isLoadingMyPosts = true;
    });

    try {
      myPosts = await ComumnityService.fetchMyPosts();
      myPostsCount = myPosts.length;
    } catch (e) {
      print("Failed to load my posts: $e");
      myPosts = [];
      myPostsCount = 0;
    }

    setState(() {
      isLoadingMyPosts = false;
      hasFetchedMyPosts = true;
    });
  }

  List<Map<String, dynamic>> get filteredUsers {
    final filtered = users
        .where((user) {
          final fullName =
              '${user['firstname']} ${user['lastname']}'.toLowerCase();
          return fullName.contains(searchQuery.toLowerCase());
        })
        .cast<Map<String, dynamic>>()
        .toList();
    return filtered.take(itemsToShow).toList();
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
                child: Text('⚠️ Waduh! Gagal muat profil: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(
                child: Text('🤷‍♂️ Data profil nggak ketemu nih!'));
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
                              _buildStatColumn('Post', myPostsCount.toString()),
                              _buildStatColumn('Teman', '0'),
                              _buildStatColumn('Fans', '0'),
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
                            profile.name + ' 😎',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${profile.bio}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
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
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsPage(
                                    profile: profile,
                                    onUpdateProfile: _updateProfile,
                                  ),
                                ),
                              );
                            },
                            icon:
                                const Icon(Icons.settings, color: Colors.green),
                            label: const Text(
                              'Atur Profil 💼',
                              style: TextStyle(color: Colors.green),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.green.shade400),
                            ),
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
                        onPressed: () async {
                          setState(() {
                            currentView = 'add';
                          });
                          if (!hasFetchedMyPosts) {
                            await loadMyPosts();
                          }
                        },
                        icon: const Icon(Icons.add_reaction_outlined),
                        iconSize: 32,
                        color: Colors.green.shade700,
                      ),
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
                        color: Colors.green.shade700,
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  if (currentView == 'add') ...[
                    const SizedBox(height: 16),
                    if (isLoadingMyPosts)
                      const Center(child: CircularProgressIndicator())
                    else if (myPosts.isEmpty) ...[
                      Center(
                        child: Column(
                          children: const [
                            Text(
                              '📸 Bagi Aktifitas Kamu!',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Belum ada postingan nih~\nYuk, bagikan momen seru kamu! 😄',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '📸 Aktivitas Postingan Community',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: myPosts.length,
                          itemBuilder: (context, index) {
                            final post = myPosts[index];
                            final community = post['community'];
                            print(community);

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0),
                              child: PostCard(
                                post: post,
                                currentUserId: currentUserId ?? 0,
                                onLikeChanged: () {
                                  setState(() {});
                                },
                                community: community,
                              ),
                            );
                          })
                    ]
                  ] else if (currentView == 'chat') ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            itemsToShow = 10;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isLoadingUsers)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(user['imageUrl'] ?? ''),
                              ),
                              title: Text(
                                  '${user['firstname']} ${user['lastname']}'),
                              subtitle: Text(user['bio'] ?? ''),
                              trailing:
                                  const Icon(Icons.chat, color: Colors.green),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      id_user_receiver: user['id'],
                                      name:
                                          '${user['firstname']} ${user['lastname']}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      if (filteredUsers.length <
                          users.where((user) {
                            final fullName =
                                '${user['firstname']} ${user['lastname']}'
                                    .toLowerCase();
                            return fullName.contains(searchQuery.toLowerCase());
                          }).length)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                itemsToShow += 10;
                              });
                            },
                            child: const Text('View More'),
                          ),
                        ),
                    ]
                  ]
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
