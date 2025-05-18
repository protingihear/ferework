import 'package:flutter/material.dart';
import 'dart:convert';

class BeritaCard extends StatelessWidget {
  final dynamic berita;
  final VoidCallback onTap;

  const BeritaCard({Key? key, required this.berita, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 250,
        height: 180,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Berita, dengan tinggi dikurangi
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 140, // tinggi gambar dikurangi supaya pas
                  color: Colors.grey[200],
                  child: berita['foto'] != null
                      ? Image.memory(
                          base64Decode(berita['foto']),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : const Center(
                          child: Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                ),
              ),
              // Konten Berita
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul berita
                      Text(
                        berita['judul'] ?? 'Judul Berita',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Deskripsi singkat
                      Expanded(
                        child: Text(
                          _getShortDescription(berita['isi']),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getShortDescription(String? fullDescription) {
    if (fullDescription == null || fullDescription.isEmpty) {
      return 'Deskripsi tidak tersedia';
    }

    // Ambil 50 kata pertama
    final words = fullDescription.split(' ');
    final shortDesc = words.length > 50
        ? '${words.take(50).join(' ')}...'
        : fullDescription;

    return shortDesc;
  }
}
