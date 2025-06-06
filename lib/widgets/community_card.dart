import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/community.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final bool isSelected;
  final int currentUserId; 

  CommunityCard({
    required this.community,
    this.isSelected = false,
    required this.currentUserId, 
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = community.creatorId == currentUserId;
    print('Debug: community.creatorId = ${community.creatorId}, currentUserId = $currentUserId, isOwner = $isOwner');
    return Stack(
      children: [
        Container(
          width: 200,
          margin: EdgeInsets.only(right: 12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border:
                isSelected ? Border.all(color: Colors.green, width: 2) : null,
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
                  : Icon(Icons.image_not_supported,
                      size: 80, color: Colors.grey),
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
        ),
        if (isOwner)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Mine',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
