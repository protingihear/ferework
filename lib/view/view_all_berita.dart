import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:reworkmobile/services/api_service.dart';

class AllBeritaPage extends StatefulWidget {
  const AllBeritaPage({Key? key}) : super(key: key);

  @override
  State<AllBeritaPage> createState() => _AllBeritaPageState();
}

class _AllBeritaPageState extends State<AllBeritaPage> {
  late Future<List<dynamic>> _beritaList;

  @override
  void initState() {
    super.initState();
    _beritaList =
        ApiService.fetchBerita(); // Panggil fungsi yang sudah kamu buat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text("Berita Terkini")),
      body: FutureBuilder<List<dynamic>>(
        future: _beritaList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada berita."));
          }

          final beritaList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: beritaList.length,
            itemBuilder: (context, index) {
              final berita = beritaList[index];
              final judul = berita['judul'] ?? '';
              final isi = berita['isi'] ?? '';
              final tanggal = berita['tanggal'] ?? '';
              final fotoBase64 = berita['foto'];
              final kategori = "derikadem"; // default jika tidak ada di API

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar
                    if (fotoBase64 != null && fotoBase64.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Image.memory(
                          base64Decode(fotoBase64),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        child: const Icon(Icons.image, color: Colors.white),
                      ),
                    // Konten
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kategori dan tanggal
                            Row(
                              children: [
                                Text(
                                  kategori,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tanggal.split("T").first,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Judul
                            Text(
                              judul,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            // Isi ringkas
                            Text(
                              isi.length > 80
                                  ? '${isi.substring(0, 80)}...'
                                  : isi,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
