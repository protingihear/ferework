import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/community.dart';

class CommunityCard extends StatelessWidget {
  final Community community;

  CommunityCard({required this.community});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Lebih besar supaya muat teks
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Decode base64 ke gambar
          community.imageBase64.isNotEmpty
              ? Image.memory(
                  base64Decode(community.imageBase64),
                  height: 80, width: 80, fit: BoxFit.cover,
                )
              : Icon(Icons.image_not_supported, size: 80, color: Colors.grey),

          SizedBox(height: 8),
          Text(
            community.name,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          Text(
            community.description,
            style: TextStyle(color: Colors.black54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

