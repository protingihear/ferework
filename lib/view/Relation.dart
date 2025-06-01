import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    communitiesFuture = fetchAndSetCommunities();
    searchController.addListener(_filterCommunities);
    loadUserId();
  }

  void loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('user_id');
    });
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
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
                    borderRadius: BorderRadius.circular(12),
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
              SizedBox(
                height: 160,
                child: filteredCommunities.isEmpty
                    ? const Center(
                        child: Text(
                          "Tidak ada komunitas ditemukan",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredCommunities.length,
                        itemBuilder: (context, index) {
                          final community = filteredCommunities[index];
                          final isSelected =
                              community.id == selectedCommunityId;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCommunityId = community.id;
                              });
                              loadPosts(community.id, community.name);
                            },
                            child: CommunityCard(
                              community: community,
                              isSelected: isSelected,
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              if (selectedCommunityId != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF77C29B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  ? const Center(
                      child: Text(
                        "Pilih komunitas untuk melihat postingan",
                        style: TextStyle(color: Colors.black87),
                      ),
                    )
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
                          return const Text(
                            "Belum ada postingan",
                            style: TextStyle(color: Colors.black54),
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
