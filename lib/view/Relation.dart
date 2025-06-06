import 'package:flutter/material.dart';
import 'package:reworkmobile/view/view_community.dart';
import 'package:reworkmobile/widgets/post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/comumnity_service.dart';
import '../models/community.dart';
import '../widgets/community_card.dart';
import './CreatePostPage.dart';
import './AddCommunityPage.dart';

class RelationsPage extends StatefulWidget {
  const RelationsPage({Key? key}) : super(key: key);

  @override
  _RelationsPageState createState() => _RelationsPageState();
}

class _RelationsPageState extends State<RelationsPage> {
  late Future<List<Community>> communitiesFuture;
  List<Community> allCommunities = [];
  List<Community> filteredCommunities = [];
  TextEditingController searchController = TextEditingController();

  Future<List<dynamic>>? posts;
  int? selectedCommunityId;
  String? selectedCommunityName;

  int? currentUserId;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    communitiesFuture = fetchAndSetCommunities();
    searchController.addListener(_filterCommunities);
    _scrollController = ScrollController();
    loadUserId();
  }

  void loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId != null) {
      setState(() {
        currentUserId = userId;
      });
    }
  }

  Future<List<Community>> fetchAndSetCommunities() async {
    final communities = await ComumnityService.fetchCommunities();
    setState(() {
      allCommunities = communities;
      filteredCommunities = communities;
    });
    return communities;
  }

  void _filterCommunities() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCommunities = allCommunities
          .where((community) => community.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void loadPosts(int communityId, String communityName) {
    setState(() {
      selectedCommunityId = communityId;
      selectedCommunityName = communityName;
      posts = ComumnityService.fetchCommunityPosts(communityId);
    });
  }

  Future<void> refreshPage() async {
    final updatedCommunities = await fetchAndSetCommunities();
    if (selectedCommunityId != null) {
      posts = ComumnityService.fetchCommunityPosts(selectedCommunityId!);
    }
    setState(() {
      communitiesFuture = Future.value(updatedCommunities);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFF3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Relations",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  hintText: "Search communities...",
                  hintStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Community",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              filteredCommunities.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Tidak ada komunitas ditemukan",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: filteredCommunities.map((community) {
                        final isSelected = community.id == selectedCommunityId;
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ViewCommunity(
                                  community: community,
                                  currentUserId: currentUserId!,
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;

                                  final tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  final offsetAnimation =
                                      animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );

                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 16,
                            child: CommunityCard(
                              community: community,
                              isSelected: isSelected,
                              currentUserId: currentUserId!,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 20),
              if (selectedCommunityId != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF77C29B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostPage(
                          communityId: selectedCommunityId!,
                          communityName: selectedCommunityName!,
                        ),
                      ),
                    );
                    if (result == true) {
                      refreshPage();
                    }
                  },
                  icon: const Icon(Icons.post_add),
                  label: const Text("Buat Post"),
                ),
              const SizedBox(height: 16),
              selectedCommunityId == null
                  ? const SizedBox.shrink()
                  : FutureBuilder<List<dynamic>>(
                      future: posts,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "Belum ada postingan",
                              style: TextStyle(color: Colors.black54),
                            ),
                          );
                        } else {
                          return Column(
                            children: snapshot.data!.map((post) {
                              return PostCard(
                                post: post,
                                currentUserId: currentUserId ?? 0,
                                onLikeChanged: () {
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          );
                        }
                      },
                    )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCommunityPage()),
          ).then((_) => refreshPage());
        },
        backgroundColor: const Color(0xFF77C29B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
