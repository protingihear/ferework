import 'package:flutter/material.dart';
import '../services/comumnity_service.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final int currentUserId;
  final VoidCallback? onLikeChanged;
  final Map<String, dynamic>? community;

  const PostCard({
    Key? key,
    required this.post,
    required this.currentUserId,
    this.onLikeChanged,
    this.community,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likeCount;
  bool showComments = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.post['likedBy']?.contains(widget.currentUserId) ?? false;
    likeCount = widget.post['likeCount'] ?? 0;
  }

  void toggleLike() async {
    try {
      if (isLiked) {
        await ComumnityService.unlikeContent(
          communityId: widget.post['communityId'].toString(),
          postId: widget.post['id'].toString(),
        );
        setState(() {
          isLiked = false;
          likeCount -= 1;
        });
        widget.post['likedBy'].remove(widget.currentUserId);
        widget.post['likeCount'] = likeCount;
      } else {
        await ComumnityService.likeContent(
          communityId: widget.post['communityId'].toString(),
          postId: widget.post['id'].toString(),
        );
        setState(() {
          isLiked = true;
          likeCount += 1;
        });
        widget.post['likedBy'].add(widget.currentUserId);
        widget.post['likeCount'] = likeCount;
      }
      if (widget.onLikeChanged != null) {
        widget.onLikeChanged!();
      }
    } catch (e) {
      print('Like/unlike failed: $e');
    }
  }

  void sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      await ComumnityService.sendReply(
        communityId: widget.post['communityId'],
        postId: widget.post['id'],
        content: content,
      );

      setState(() {
        widget.post['replies'] ??= [];
        widget.post['replies'].add({
          'author': {
            'id': widget.currentUserId,
            'username': 'You',
          },
          'content': content,
        });
        _commentController.clear();
        FocusScope.of(context).unfocus();
      });
    } catch (e) {
      print('Failed to send comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

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
          // User Info
          Row(
            children: [
              if (widget.community == null) ...[
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    post['author']?['avatarUrl'] ??
                        'https://via.placeholder.com/150',
                  ),
                  radius: 20,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                widget.community?['name'] ?? post['author']['username'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Post Content
          Text(
            post['content'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons (like, comment, share)
          Row(
            children: [
              GestureDetector(
                onTap: toggleLike,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isLiked ? Colors.red : Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likeCount',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showComments = !showComments;
                  });
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.mode_comment_outlined,
                      size: 20,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['replies']?.length ?? 0}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.share_outlined,
                size: 20,
                color: Colors.black54,
              ),
            ],
          ),
          // Comment Section
          if (showComments) ...[
            const SizedBox(height: 12),
            // List of comments
            ...List<Widget>.from((post['replies'] ?? []).map<Widget>((reply) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.account_circle,
                        size: 20, color: Colors.black45),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${reply['author']['username']}: ${reply['content']}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            })),
            const SizedBox(height: 8),
            // Comment input field
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tulis komentar...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: sendComment,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text("Kirim"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            )
          ],
        ],
      ),
    );
  }
}
