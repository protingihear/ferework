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

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json["_id"],
      name: json["name"],
      username: json["username"],
      participants: List<String>.from(json["participants"]),
      isGroup: json["isGroup"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
