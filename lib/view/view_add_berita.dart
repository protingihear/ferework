import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:reworkmobile/services/berita_service.dart';

class ViewAddBeritaPage extends StatefulWidget {
  const ViewAddBeritaPage({super.key});

  @override
  State<ViewAddBeritaPage> createState() => _ViewAddBeritaPageState();
}

class _ViewAddBeritaPageState extends State<ViewAddBeritaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final compressed = await _compressImage(File(picked.path));
      setState(() {
        _pickedImage = compressed;
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final xfile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 480,
      minHeight: 640,
    );

    if (xfile == null) return file;

    return File(xfile.path);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await BeritaService.uploadBerita(
        judul: _judulController.text,
        isi: _isiController.text,
        tanggal: _selectedDate,
        foto: _pickedImage,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Berita berhasil ditambahkan')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Gagal menambahkan berita')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final softGreen = const Color(0xFFD0F0C0);

    return Scaffold(
      backgroundColor: softGreen,
      appBar: AppBar(
        title: const Text("Tambah Berita"),
        backgroundColor: const Color(0xFF98DFAF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration("Judul Berita"),
                validator: (value) =>
                    value!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _isiController,
                decoration: _inputDecoration("Isi Berita"),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Isi wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.date_range, color: Colors.green[700]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tanggal: ${_selectedDate.toLocal().toString().split(" ")[0]}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) => Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF98DFAF),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: const Text("Pilih"),
                  )
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                    image: _pickedImage != null
                        ? DecorationImage(
                            image: FileImage(_pickedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pickedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo_rounded,
                                size: 40, color: Colors.green),
                            SizedBox(height: 8),
                            Text("Tap untuk pilih gambar",
                                style: TextStyle(color: Colors.green)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text("Kirim Berita"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF98DFAF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.green),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.green),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.green),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    );
  }
}
