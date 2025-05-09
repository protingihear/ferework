import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String name;
  final String username;
  final List<String> participants;
  final bool isGroup;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.name,
    required this.username,
    required this.participants,
    required this.isGroup,
    required this.createdAt,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatRoom(
      id: doc.id,
      name: data["name"] ?? '',
      username: data["username"] ?? '',
      participants: List<String>.from(data["participants"] ?? []),
      isGroup: data["isGroup"] ?? false,
      createdAt: (data["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "username": username,
      "participants": participants,
      "isGroup": isGroup,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}
