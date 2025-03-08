import 'package:flutter/material.dart';
import '../services/comumnity_service.dart';

class CreatePostPage extends StatefulWidget {
  final int communityId;

  CreatePostPage({required this.communityId});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  void _submitPost() async {
    if (_contentController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.createPost(widget.communityId, "Anonymous", _contentController.text);
      Navigator.pop(context, true); // Kembalikan true agar halaman sebelumnya bisa refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal membuat post: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buat Postingan")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Tulis sesuatu...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitPost,
                    child: Text("Posting"),
                  ),
          ],
        ),
      ),
    );
  }
}
