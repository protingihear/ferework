import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../services/comumnity_service.dart';

class AddCommunityPage extends StatefulWidget {
  @override
  _AddCommunityPageState createState() => _AddCommunityPageState();
}

class _AddCommunityPageState extends State<AddCommunityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  String? _base64Image;

  final ImagePicker _picker = ImagePicker();

  // 🔹 Fungsi untuk memilih dan mengompres gambar
  Future<void> _pickAndCompressImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    // 🔹 Kompres gambar hingga kurang dari 2MB
    File? compressedImage = await _compressImage(imageFile);

    if (compressedImage != null) {
      List<int> imageBytes = await compressedImage.readAsBytes();
      String base64String = base64Encode(imageBytes);

      setState(() {
        _selectedImage = compressedImage;
        _base64Image = base64String;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gambar terlalu besar! Pilih gambar lain.")),
      );
    }
  }

  // 🔹 Fungsi untuk mengompres gambar hingga kurang dari 2MB
  Future<File?> _compressImage(File file) async {
    int fileSize = await file.length();
    
    if (fileSize <= 2 * 1024 * 1024) return file; // Jika sudah <2MB, langsung pakai

    String targetPath = file.path.replaceAll(".jpg", "_compressed.jpg");

    int quality = 90;
    File? compressedFile;

    while (fileSize > 2 * 1024 * 1024 && quality > 10) {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: quality,
      );

      if (result != null) {
        compressedFile = File(result.path);
        fileSize = await compressedFile.length();
      }

      quality -= 10; // Kurangi kualitas jika masih terlalu besar
    }

    return fileSize <= 2 * 1024 * 1024 ? compressedFile : null;
  }

  void _submitCommunity() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua field harus diisi!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.createCommunity(
        _nameController.text,
        _descriptionController.text,
        _base64Image!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Komunitas berhasil dibuat!")),
      );

      Navigator.pop(context, true); // Tutup halaman dan refresh sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Gagal membuat komunitas: $e")),
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
      appBar: AppBar(title: Text("Buat Komunitas")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nama Komunitas",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),

            // 🔹 Pratinjau gambar yang dipilih
            _selectedImage != null
                ? Column(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(_selectedImage!, height: 150),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                                _base64Image = null;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  )
                : Container(),

            // 🔹 Tombol untuk memilih gambar
            _selectedImage == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickAndCompressImage(ImageSource.camera),
                        icon: Icon(Icons.camera_alt),
                        label: Text("Kamera"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickAndCompressImage(ImageSource.gallery),
                        icon: Icon(Icons.image),
                        label: Text("Galeri"),
                      ),
                    ],
                  )
                : Container(),

            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitCommunity,
                      child: Text("Buat Komunitas"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
