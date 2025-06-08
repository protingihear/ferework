import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:reworkmobile/view/relation/post/CreatePostPage.dart';
import 'package:reworkmobile/view/relation/community/view_edit_community.dart';
import 'package:reworkmobile/widgets/post_card.dart';
import '../../../models/community.dart';
import '../../../services/comumnity_service.dart';

const Color kGreenSoft = Color(0xFFE8F5E9);
const Color kGreenMid = Color(0xFF81C784);
const Color kGreenDark = Color(0xFF388E3C);
const Color kGreenLightAccent = Color(0xFFB3E5FC);

class ViewCommunity extends StatefulWidget {
  final Community community;
  final int currentUserId;

  const ViewCommunity({
    Key? key,
    required this.community,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ViewCommunity> createState() => _ViewCommunityState();
}

class _ViewCommunityState extends State<ViewCommunity> {
  bool isJoined = false;
  bool loading = false;
  bool isLoadingPosts = true;
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    loadPosts();
    checkMembership();
  }

  Future<void> loadPosts() async {
    try {
      final fetchedPosts =
          await ComumnityService.fetchCommunityPosts(widget.community.id);
      setState(() {
        posts = fetchedPosts;
        isLoadingPosts = false;
      });
      print(posts);
    } catch (e) {
      print("Failed to load posts: $e");
      setState(() {
        isLoadingPosts = false;
      });
    }
  }

  Future<void> checkMembership() async {
    try {
      final joinedCommunities = await ComumnityService.getJoinedCommunities();
      final isCurrentlyJoined = joinedCommunities.any(
        (community) => community['id'] == widget.community.id,
      );
      setState(() {
        isJoined = isCurrentlyJoined;
      });
    } catch (e) {
      print("Failed to check membership: $e");
      setState(() {
        isJoined = false;
      });
    }
  }

  Future<void> toggleMembership() async {
    setState(() {
      loading = true;
    });

    try {
      if (isJoined) {
        await ComumnityService.leaveCommunity(widget.community.id);
      } else {
        await ComumnityService.joinCommunity(widget.community.id);
      }

      setState(() {
        isJoined = !isJoined;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final community = widget.community;
    final isOwner = widget.currentUserId == community.creatorId;

    return Scaffold(
      backgroundColor: kGreenSoft,
      appBar: AppBar(
        backgroundColor: kGreenMid,
        elevation: 0,
        title: Text(
          community.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: community.imageBase64.isNotEmpty
                            ? MemoryImage(base64Decode(community.imageBase64))
                            : null,
                        child: community.imageBase64.isEmpty
                            ? const Icon(Icons.group,
                                size: 40, color: Colors.white54)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              community.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              community.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (!isOwner) ...[
                                  SizedBox(
                                    width: 80,
                                    height: 34,
                                    child: ElevatedButton(
                                      onPressed:
                                          loading ? null : toggleMembership,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isJoined
                                            ? Colors.redAccent
                                            : kGreenMid,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        isJoined ? 'Leave' : 'Join',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ),
                                  if (isJoined)
                                    SizedBox(
                                      width: 80,
                                      height: 34,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CreatePostPage(
                                                communityId: community.id,
                                                communityName: community.name,
                                              ),
                                            ),
                                          );
                                          if (result == true) await loadPosts();
                                        },
                                        icon: const Icon(Icons.post_add,
                                            size: 14),
                                        label: const Text("Post",
                                            style: TextStyle(fontSize: 11)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kGreenLightAccent,
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                ] else ...[
                                  SizedBox(
                                    width: 80,
                                    height: 34,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CreatePostPage(
                                              communityId: community.id,
                                              communityName: community.name,
                                            ),
                                          ),
                                        );
                                        if (result == true) await loadPosts();
                                      },
                                      icon:
                                          const Icon(Icons.post_add, size: 14),
                                      label: const Text("Post",
                                          style: TextStyle(fontSize: 11),),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kGreenLightAccent,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    height: 34,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditCommunityPage(
                                              communityId: community.id,
                                              initialName: community.name,
                                              initialDescription:
                                                  community.description,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                                      label: const Text("Edit",
                                          style: TextStyle(fontSize: 11, color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kGreenDark,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    height: 34,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title:
                                                const Text("Hapus Komunitas"),
                                            content: const Text(
                                                "Apakah kamu yakin ingin menghapus komunitas ini?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text("Batal")),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text("Hapus",
                                                      style: TextStyle(
                                                          color: Colors.red))),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await ComumnityService
                                              .deleteCommunity(
                                                  widget.community.id);
                                          if (mounted) Navigator.pop(context);
                                        }
                                      },
                                      icon: const Icon(Icons.delete, size: 14, color: Colors.white),
                                      label: const Text("Delete",
                                          style: TextStyle(fontSize: 11, color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Community Posts",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          isLoadingPosts
              ? const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: kGreenMid)),
                )
              : posts.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "Belum ada post di komunitas ini.",
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: PostCard(
                              post: post,
                              currentUserId: widget.currentUserId,
                              onLikeChanged: () {
                                setState(() {});
                              },
                            ),
                          );
                        },
                        childCount: posts.length,
                      ),
                    ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
