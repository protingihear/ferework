import 'package:flutter/material.dart';
import 'package:reworkmobile/services/berita_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BeritaDetail extends StatefulWidget {
  final dynamic berita;

  const BeritaDetail({Key? key, required this.berita}) : super(key: key);

  @override
  State<BeritaDetail> createState() => _BeritaDetailState();
}

class _BeritaDetailState extends State<BeritaDetail> {
  String? role;
  
  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson == null) return null;

    final Map<String, dynamic> userMap = jsonDecode(userJson);
    return userMap['role'] as String?;
  }

  Future<void> _loadRole() async {
    final r = await getUserRole();
    setState(() {
      role = r;
    });
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus berita ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BeritaService.deleteBerita(widget.berita['id']);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const softGreen = Color(0xFFD0F0C0);
    const mainGreen = Color(0xFF98DFAF);
    print(widget.berita);
    return Scaffold(
      backgroundColor: softGreen,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol Close & Delete
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: mainGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  if (role == 'ahli_bahasa')
                    GestureDetector(
                      onTap: _confirmDelete,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),

            // Isi Berita
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar
                    Center(
                      child: widget.berita['foto'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                base64Decode(widget.berita['foto']),
                                width: 150,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(Icons.image,
                                    size: 50, color: Colors.white),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Judul
                    Text(
                      widget.berita['judul'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Isi Berita
                    Text(
                      widget.berita['isi'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
