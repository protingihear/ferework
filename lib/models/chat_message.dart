class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String username;
  final String message;
  final String messageType;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.username,
    required this.message,
    required this.messageType,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json["_id"],
      chatRoomId: json["chatRoomId"],
      senderId: json["senderId"],
      username: json["username"],
      message: json["message"],
      messageType: json["messageType"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
