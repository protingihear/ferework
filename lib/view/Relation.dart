import 'package:flutter/material.dart';
import '../services/comumnity_service.dart';
import '../models/community.dart';
import '../widgets/community_card.dart';
import './CreatePostPage.dart';
import './AddCommunityPage.dart';

class RelationsPage extends StatefulWidget {
  @override
  _RelationsPageState createState() => _RelationsPageState();
}

class _RelationsPageState extends State<RelationsPage> {
  late Future<List<Community>> communities;
  Future<List<dynamic>>? posts;
  int? selectedCommunityId;
  Map<int, bool> joinedCommunities = {}; // Status keanggotaan komunitas

  @override
  void initState() {
    super.initState();
    communities = ApiService.fetchCommunities();
  }

  void loadPosts(int communityId) {
    setState(() {
      selectedCommunityId = communityId;
      posts = ApiService.fetchCommunityPosts(communityId);
    });
  }

  Future<void> refreshPage() async {
    setState(() {
      communities = ApiService.fetchCommunities();
      if (selectedCommunityId != null) {
        posts = ApiService.fetchCommunityPosts(selectedCommunityId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Relations", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),

              // Title "Community"
              Text("Community", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 8),

              // Fetch data & show in ListView
              FutureBuilder<List<Community>>(
                future: communities,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No communities found", style: TextStyle(color: Colors.black));
                  } else {
                    return SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final community = snapshot.data![index];
                          final bool isJoined = joinedCommunities[community.id] ?? false;

                          return GestureDetector(
                            onTap: () {
                              loadPosts(community.id);
                            },
                            child: Stack(
                              children: [
                                CommunityCard(community: community),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: ElevatedButton(
                                    onPressed: isJoined
                                        ? null
                                        : () async {
                                            try {
                                              await ApiService.joinCommunity(community.id);
                                              setState(() {
                                                joinedCommunities[community.id] = true;
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Berhasil bergabung ke komunitas")),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Gagal bergabung: $e")),
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isJoined ? Colors.grey : Colors.blue,
                                    ),
                                    child: Text(isJoined ? "Joined" : "Join"),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),

              SizedBox(height: 16),

              // Tombol buat postingan
              if (selectedCommunityId != null)
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostPage(communityId: selectedCommunityId!),
                      ),
                    );

                    if (result == true) {
                      refreshPage();
                    }
                  },
                  child: Text("Buat Post"),
                ),
              SizedBox(height: 16),

              // Postingan komunitas berdasarkan yang dipilih
              selectedCommunityId == null
                  ? Center(child: Text("Pilih komunitas untuk melihat postingan", style: TextStyle(color: Colors.black)))
                  : FutureBuilder<List<dynamic>>(
                      future: posts,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text("Belum ada postingan", style: TextStyle(color: Colors.black));
                        } else {
                          return Column(
                            children: snapshot.data!.map((post) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(post['author']['username'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                    SizedBox(height: 8),
                                    Text(post['content'], style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
            ],
          ),
        ),
      ),

      // ✅ FAB untuk pindah halaman
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCommunityPage()),
          ).then((_) => refreshPage()); // Setelah kembali, refresh halaman
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
