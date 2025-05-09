class ChatMessage {
  final int senderId;
  final String message;
  final DateTime? timestamp;

  ChatMessage({
    required this.senderId,
    required this.message,
    this.timestamp,
  });
}
