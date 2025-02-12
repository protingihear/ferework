import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadBeritaScreen(),
    );
  }
}

class UploadBeritaScreen extends StatefulWidget {
  @override
  _UploadBeritaScreenState createState() => _UploadBeritaScreenState();
}

class _UploadBeritaScreenState extends State<UploadBeritaScreen> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  File? _image;
  String? _base64Image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);

      setState(() {
        _image = imageFile;
        _base64Image = base64String;
      });
    }
  }

  Future<void> _uploadBerita() async {
    if (_judulController.text.isEmpty ||
        _isiController.text.isEmpty ||
        _tanggalController.text.isEmpty ||
        _base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Semua field dan foto harus diisi")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("http://localhost:5000/api/berita");
    final Map<String, dynamic> body = {
      "judul": _judulController.text,
      "isi": _isiController.text,
      "tanggal": _tanggalController.text,
      "foto": _base64Image, // Kirim foto sebagai Base64
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Berita berhasil diunggah!")));
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal mengunggah berita! (${response.statusCode})")));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Terjadi kesalahan jaringan!")));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Berita")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _judulController,
              decoration: InputDecoration(labelText: "Judul"),
            ),
            TextField(
              controller: _isiController,
              decoration: InputDecoration(labelText: "Isi Berita"),
              maxLines: 3,
            ),
            TextField(
              controller: _tanggalController,
              decoration: InputDecoration(labelText: "Tanggal (YYYY-MM-DD)"),
            ),
            SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 150)
                : Text("Belum ada foto"),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pilih Gambar"),
            ),
            SizedBox(height: 10),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadBerita,
                    child: Text("Upload Berita"),
                  ),
          ],
        ),
      ),
    );
  }
}
