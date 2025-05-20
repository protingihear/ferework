import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    communitiesFuture = fetchAndSetCommunities();
    searchController.addListener(_filterCommunities);
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

  void loadPosts(int communityId) {
    setState(() {
      selectedCommunityId = communityId;
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
              // Search Bar
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

              // Title "Community"
              const Text(
                "Community",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // List komunitas
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
                          return GestureDetector(
                            onTap: () => loadPosts(community.id),
                            child: CommunityCard(community: community),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),

              // Tombol buat postingan
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
                        builder: (context) =>
                            CreatePostPage(communityId: selectedCommunityId!),
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

              // Postingan komunitas
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
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD3F0D0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            post['author']['avatarUrl'] ??
                                                'https://via.placeholder.com/150',
                                          ),
                                          radius: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          post['author']['username'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      post['content'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.favorite_border,
                                            size: 20, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${post['likes'] ?? 0}',
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.mode_comment_outlined,
                                            size: 20, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${post['comments'] ?? 0}',
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.share_outlined,
                                            size: 20, color: Colors.black54),
                                      ],
                                    ),
                                  ],
                                ),
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

      // Tombol tambah komunitas
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
