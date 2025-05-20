import 'package:flutter/material.dart';
import 'dart:convert';

class BeritaDetail extends StatelessWidget {
  final dynamic berita;

  const BeritaDetail({Key? key, required this.berita}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const softGreen = Color(0xFFD0F0C0);
    const mainGreen = Color(0xFF98DFAF);

    return Scaffold(
      backgroundColor: softGreen,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol Close
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
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
                    berita['foto'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              base64Decode(berita['foto']),
                              width: double.infinity,
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
                              child: Icon(Icons.image, size: 50, color: Colors.white),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Judul
                    Text(
                      berita['judul'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Isi Berita
                    Text(
                      berita['isi'] ?? '',
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
