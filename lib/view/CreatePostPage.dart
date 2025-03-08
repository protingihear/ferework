import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Konten tidak boleh kosong!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      final ttCookie = prefs.getString('tt_cookie');

      if (sessionCookie == null || ttCookie == null) {
        throw Exception("Session tidak ditemukan. Harap login terlebih dahulu.");
      }

      print("📌 Posting ke Community ID: ${widget.communityId}");
      await ApiService.createPost(widget.communityId, _contentController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Post berhasil dibuat!")),
      );

      Navigator.pop(context, true); // Refresh halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Gagal membuat post: $e")),
      );
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Community ID: ${widget.communityId}", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
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
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitPost,
                      child: Text("Posting"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
