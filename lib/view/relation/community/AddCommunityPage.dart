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
  // Warna hijau lembut dominan
  final Color kGreenVerySoft = const Color(0xFFF1F8E9);
  final Color kGreenSoft = const Color(0xFFC8E6C9);
  final Color kGreenLight = const Color(0xFF81C784);
  final Color kGreenAccent = const Color(0xFF66BB6A);
  final Color kGreenDark = const Color(0xFF388E3C);

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

      final compressed = await FlutterImageCompress.compressAndGetFile(
        picked.path,
        targetPath,
        minWidth: 480,
        minHeight: 640,
        quality: 40,
      );

      if (compressed != null) {
        setState(() {
          _selectedImage = File(compressed.path);
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
      backgroundColor: kGreenVerySoft,
      appBar: AppBar(
        backgroundColor: kGreenLight,
        title: const Text("Tambah Komunitas"),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 25,
                decoration: InputDecoration(
                  labelText: 'Nama Komunitas',
                  filled: true,
                  fillColor: kGreenSoft,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  if (val.length > 25) return 'Maksimal 25 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  filled: true,
                  fillColor: kGreenSoft,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  if (val.length > 100) return 'Maksimal 100 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: kGreenSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGreenLight, width: 1.5),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            'Klik untuk pilih gambar',
                            style: TextStyle(color: kGreenDark),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                key: const Key('submitCommunity'),
                onPressed: _isLoading ? null : _submit,
                icon: const Icon(Icons.send),
                label: Text(_isLoading ? "Mengirim..." : "Buat Komunitas"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
