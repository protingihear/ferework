// import 'package:flutter/material.dart';
// import '../services/chat_service.dart';
// import '../models/chat_message.dart';

// class ChatPage extends StatefulWidget {
//   final String roomId;
//   final String userId; // Your logged-in user ID

//   ChatPage({required this.roomId, required this.userId});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final ChatService chatService = ChatService();
//   List<ChatMessage> messages = [];
//   TextEditingController messageController = TextEditingController();
//   TextEditingController searchController = TextEditingController();

//   bool isSearching = false;
//   String searchQuery = "";

//   @override
//   void initState() {
//     super.initState();
//     fetchMessages();
//   }

//   Future<void> fetchMessages() async {
//     List<ChatMessage> fetchedMessages =
//         await chatService.getMessages(widget.roomId);

//     if (!mounted) return;

//     setState(() {
//       messages = fetchedMessages;
//     });
//   }

//   Future<void> sendMessage() async {
//     String messageText = messageController.text.trim();
//     if (messageText.isNotEmpty) {
//       await chatService.sendMessage(widget.roomId, messageText);
//       messageController.clear();
//       fetchMessages(); // Refresh after sending
//     }
//   }

//   void startSearch() {
//     setState(() {
//       isSearching = true;
//     });
//   }

//   void stopSearch() {
//     setState(() {
//       isSearching = false;
//       searchQuery = "";
//       searchController.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: CircleAvatar(
//             backgroundColor: Colors.green,
//             child: IconButton(
//               icon: Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//         ),
//         title: isSearching
//             ? TextField(
//                 controller: searchController,
//                 autofocus: true,
//                 decoration: InputDecoration(
//                   hintText: "Search messages...",
//                   border: InputBorder.none,
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     searchQuery = value.toLowerCase();
//                   });
//                 },
//                 onSubmitted: (_) => stopSearch(),
//               )
//             : Text(
//                 "Puri Lalita Anagata",
//                 style:
//                     TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//               ),
//         actions: [
//           if (isSearching)
//             IconButton(
//               icon: Icon(Icons.close, color: Colors.red),
//               onPressed: stopSearch,
//             )
//           else
//             IconButton(
//               icon: Icon(Icons.search, color: Colors.blue),
//               onPressed: startSearch,
//             )
//         ],
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: messages.isEmpty
//                 ? Center(child: Text("No messages found."))
//                 : ListView.builder(
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final msg = messages[index];
//                       bool isMe =
//                           msg.senderId.toString() == widget.userId.toString();
//                       bool matchesSearch = searchQuery.isEmpty ||
//                           msg.message.toLowerCase().contains(searchQuery);

//                       return matchesSearch
//                           ? Align(
//                               alignment: isMe
//                                   ? Alignment.centerRight
//                                   : Alignment.centerLeft,
//                               child: Container(
//                                 margin: EdgeInsets.symmetric(
//                                     vertical: 5, horizontal: 10),
//                                 padding: EdgeInsets.all(12),
//                                 constraints: BoxConstraints(
//                                     maxWidth:
//                                         MediaQuery.of(context).size.width *
//                                             0.7),
//                                 decoration: BoxDecoration(
//                                   color: isMe
//                                       ? Colors.blue[400]
//                                       : Colors.green[200],
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(10),
//                                     topRight: Radius.circular(10),
//                                     bottomLeft: isMe
//                                         ? Radius.circular(10)
//                                         : Radius.zero,
//                                     bottomRight: isMe
//                                         ? Radius.zero
//                                         : Radius.circular(10),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   msg.message,
//                                   style: TextStyle(
//                                       color: isMe ? Colors.white : Colors.black,
//                                       backgroundColor: searchQuery.isNotEmpty &&
//                                               msg.message
//                                                   .toLowerCase()
//                                                   .contains(searchQuery)
//                                           ? Colors.yellow[300]
//                                           : null), // Highlight search results
//                                 ),
//                               ),
//                             )
//                           : Container(); // Hide non-matching messages
//                     },
//                   ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: TextField(
//                       controller: messageController,
//                       decoration: InputDecoration(
//                         hintText: "Ketik pesanmu disini",
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 SizedBox(width: 8),
//                 CircleAvatar(
//                   backgroundColor: Colors.blue,
//                   child: IconButton(
//                     icon: Icon(Icons.send, color: Colors.white),
//                     onPressed: sendMessage,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
