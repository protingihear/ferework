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
        width: 260,
        height: 190,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: const Color(0xFFE8F5E9), // hijau kalem
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Berita
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFFC8E6C9), // warna latar hijau muda
                  child: berita['foto'] != null
                      ? Image.memory(
                          base64Decode(berita['foto']),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : const Center(
                          child: Icon(Icons.image_outlined,
                              size: 50, color: Color(0xFF81C784)),
                        ),
                ),
              ),
              // Konten Berita
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        berita['judul'] ?? 'Judul Berita',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: Color(0xFF2E7D32), // hijau tua
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          _getShortDescription(berita['isi']),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4CAF50),
                            height: 1.4,
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

    final words = fullDescription.split(' ');
    return words.length > 50
        ? '${words.take(50).join(' ')}...'
        : fullDescription;
  }
}
