import 'package:flutter/material.dart';

class AddPostPage extends StatelessWidget {
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Postingan"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tulis Postingan:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Apa yang ingin kamu bagikan?",
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Nanti tambahkan API untuk submit post
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Postingan ditambahkan!")),
                );
                Navigator.pop(context); // Kembali ke halaman utama
              },
              child: Text("Tambah Postingan"),
            ),
          ],
        ),
      ),
    );
  }
}
