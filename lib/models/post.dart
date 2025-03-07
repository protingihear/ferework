import 'package:flutter/material.dart';
import 'dart:convert';

class BeritaDetail extends StatelessWidget {
  final dynamic berita;

  const BeritaDetail({Key? key, required this.berita}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Ensures it doesn’t go under status bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close Button Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    berita['foto'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              base64Decode(berita['foto']),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),
                    SizedBox(height: 10),
                    Text(
                      berita['judul'],
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      berita['isi'],
                      style: TextStyle(fontSize: 16),
                    ),
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