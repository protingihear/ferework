import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/chat_message.dart';


class ChatScreen extends StatefulWidget {
  final int id_user_receiver;
  final String? name;

  const ChatScreen({
    super.key,
    required this.id_user_receiver,
    this.name,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  String? _chatRoomId;
  int? _userId;

  String get _displayName =>
      (widget.name?.isNotEmpty ?? false) ? widget.name! : "Guest IHear";

  @override
  void initState() {
    super.initState();
    _initUserAndRoom();
  }

  Future<void> _initUserAndRoom() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');

    if (_userId == null) {
      print("❌ User ID not found in SharedPreferences");
      return;
    }

    final roomId = _generateRoomId(_userId!, widget.id_user_receiver);
    setState(() {
      _chatRoomId = roomId;
    });

    // Buat dokumen room jika belum ada
    final roomDoc =
        FirebaseFirestore.instance.collection('chat_rooms').doc(roomId);

    final snapshot = await roomDoc.get();
    if (!snapshot.exists) {
      await roomDoc.set({
        'participants': [_userId, widget.id_user_receiver],
        'lastMessage': '',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print("✅ Room dibuat: $roomId");
    } else {
      print("✅ Room ditemukan: $roomId");
    }
  }

  String _generateRoomId(int senderId, int receiverId) {
    // Buat ID unik berdasarkan 2 user id (urutan tidak masalah)
    final ids = [senderId, receiverId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatRoomId == null || _userId == null) return;

    final roomDoc =
        FirebaseFirestore.instance.collection('chat_rooms').doc(_chatRoomId);
    final message = {
      'senderId': _userId,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await roomDoc.collection('messages').add(message);

    // Update metadata room
    await roomDoc.update({
      'lastMessage': text,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: _chatRoomId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chat_rooms')
                        .doc(_chatRoomId)
                        .collection('messages')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("Belum ada pesan"));
                      }

                      final messages = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ChatMessage(
                          senderId: data['senderId'],
                          message: data['message'],
                          timestamp: data['timestamp']?.toDate(),
                        );
                      }).toList();

                      return ListView.builder(
                        itemCount: messages.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isSender = msg.senderId == _userId;
                          return _chatBubble(msg.message, isSender: isSender);
                        },
                      );
                    },
                  ),
          ),
          _messageInput(),
        ],
      ),
    );
  }

  Widget _chatBubble(String text, {required bool isSender}) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue[100] : Colors.green[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _messageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Ketik pesanmu di sini',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _handleSendMessage,
            ),
          ),
        ],
      ),
    );
  }
}