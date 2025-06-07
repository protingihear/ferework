import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/comumnity_service.dart';

const Color kGreenVerySoft = Color(0xFFF1F8E9);
const Color kGreenSoft = Color(0xFFC8E6C9);
const Color kGreenLight = Color(0xFF81C784);
const Color kGreenBright = Color(0xFFA5D6A7);
const Color kGreenAccent = Color(0xFF66BB6A);
const Color kGreenDark = Color(0xFF388E3C);

class CreatePostPage extends StatefulWidget {
  final int communityId;
  final String communityName;

  CreatePostPage({required this.communityId, required this.communityName});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🚫 Konten tidak boleh kosong!")),
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
      await ComumnityService.createPost(widget.communityId, _contentController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Post berhasil dibuat!")),
      );

      Navigator.pop(context, true);
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
      backgroundColor: kGreenVerySoft,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.edit, color: kGreenLight),
            SizedBox(width: 8),
            Text(
              "Buat Postingan",
              style: TextStyle(color: kGreenLight, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: kGreenSoft,
        elevation: 0,
        iconTheme: IconThemeData(color: kGreenLight),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📢 Posting ke komunitas: ${widget.communityName}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kGreenAccent,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kGreenSoft.withOpacity(0.6),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                style: TextStyle(color: kGreenDark),
                decoration: InputDecoration(
                  hintText: "Tulis sesuatu yang menyenangkan dan berkesan",
                  hintStyle: TextStyle(color: kGreenLight.withOpacity(0.7)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            SizedBox(height: 24),
            _isLoading
                ? Center(child: CircularProgressIndicator(color: kGreenLight))
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreenLight,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                      onPressed: _submitPost,
                      icon: Icon(Icons.send, color: Colors.white),
                      label: Text(
                        "Posting Sekarang!",
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
