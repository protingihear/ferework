import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

class ChatService {
  static const String _baseUrl = 'https://berework-production-ad0a.up.railway.app';

  Future<String?> _getSessionCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_cookie');
  }

  Future<Map<String, String>> _getHeaders() async {
    String? sessionCookie = await _getSessionCookie();
    return {
      "Content-Type": "application/json",
      if (sessionCookie != null) "Cookie": "session_id=$sessionCookie",
    };
  }

  /// **1️⃣ Create Chat Room**
  Future<ChatRoom?> createRoom(String name) async {
    final url = Uri.parse("$_baseUrl/api/chat/create-room");
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({"name": name}),
    );

    if (response.statusCode == 200) {
      return ChatRoom.fromJson(jsonDecode(response.body)["chatRoom"]);
    }
    return null;
  }

  /// Get Messages in Room
  Future<List<ChatMessage>> getMessages(String roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_cookie');
      final tt = prefs.getString('tt_cookie');

      if (sessionId == null || tt == null) {
        throw Exception("Session ID or tt not found");
      }

      final url = Uri.parse("$_baseUrl/api/$roomId/messages");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Cookie": "session_id=$sessionId; tt=$tt",
        },
      );

      // 🔍 Debugging API response
      print("📡 Fetching messages from: $url");
      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // 🔍 Debugging Parsed Data
        print("📜 Parsed Messages Count: ${data.length}");
        for (var msg in data) {
          print("📝 Message: ${msg["message"]} from ${msg["username"]}");
        }

        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception(
            "Failed to fetch messages, status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching messages: $e");
      return [];
    }
  }

  /// Send Message
  Future<void> sendMessage(String roomId, String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_cookie');
      final tt = prefs.getString('tt_cookie');
      final userId = prefs.getInt('user_id'); // ✅ Get sender ID

      if (sessionId == null || tt == null || userId == null) {
        throw Exception("Missing authentication credentials");
      }

      final url = Uri.parse("$_baseUrl/api/chat/rooms/$roomId/messages");
      final headers = {
        "Content-Type": "application/json",
        "Cookie": "session_id=$sessionId; tt=$tt",
      };

      final body = jsonEncode({
        "message": message,
        "messageType": "text",
        "senderId": userId.toString(), // ✅ Add sender ID
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("📡 Sending message to: $url");
      print("📤 Request Body: $body");
      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Message sent successfully!");
      } else {
        throw Exception(
            "Failed to send message, status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error sending message: $e");
    }
  }

  /// **4️⃣ Get Room Users**
  Future<List<String>> getRoomUsers(String roomId) async {
    final url = Uri.parse("$_baseUrl/api/chat/room-users/$roomId");
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    return [];
  }
}
