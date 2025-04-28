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
        title: Text(
          "Relations",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),

              // Title "Community"
              Text(
                "Community",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),

              // List komunitas
              FutureBuilder<List<Community>>(
                future: communities,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                      "No communities found",
                      style: TextStyle(color: Colors.black),
                    );
                  } else {
                    return SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final community = snapshot.data![index];

                          return GestureDetector(
                            onTap: () {
                              loadPosts(community.id);
                            },
                            child: CommunityCard(community: community),
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

              // Postingan komunitas
              selectedCommunityId == null
                  ? Center(
                      child: Text(
                        "Pilih komunitas untuk melihat postingan",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  : FutureBuilder<List<dynamic>>(
                      future: posts,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text(
                            "Belum ada postingan",
                            style: TextStyle(color: Colors.black),
                          );
                        } else {
                          return Column(
                            children: snapshot.data!.map((post) {
                              return InkWell(
                                onTap: () {},
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD3F0D0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post['author']['username'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        post['content'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
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

      // Tombol tambah komunitas
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCommunityPage()),
          ).then((_) => refreshPage());
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}