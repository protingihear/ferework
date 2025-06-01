import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/community.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final bool isSelected;

  CommunityCard({
    required this.community,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isSelected ? Colors.green[100] : Colors.grey[200], // ← ini kuncinya
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: Colors.green, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          community.imageBase64.isNotEmpty
              ? Image.memory(
                  base64Decode(community.imageBase64),
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                )
              : Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            community.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
