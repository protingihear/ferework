import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reworkmobile/services/comumnity_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class AddCommunityPage extends StatefulWidget {
  const AddCommunityPage({Key? key}) : super(key: key);

  @override
  State<AddCommunityPage> createState() => _AddCommunityPageState();
}

class _AddCommunityPageState extends State<AddCommunityPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Kompres file
      final compressed = await FlutterImageCompress.compressAndGetFile(
        picked.path,
        targetPath,
        minWidth: 480,
        minHeight: 640,
        quality: 40,
      );

      if (compressed != null) {
        setState(() {
          _selectedImage = File(compressed.path); // Fix: konversi ke File
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ComumnityService.createCommunity(
        name: _nameController.text,
        description: _descController.text,
        imageFile: _selectedImage,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🎉 Komunitas berhasil dibuat!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Gagal membuat komunitas.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❗ Terjadi kesalahan: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Komunitas")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nama komunitas
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Komunitas',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Gambar
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(child: Text('Klik untuk pilih gambar')),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol submit
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: const Icon(Icons.send),
                label: Text(_isLoading ? "Mengirim..." : "Buat Komunitas"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
