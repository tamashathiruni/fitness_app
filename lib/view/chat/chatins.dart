import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  static String routeName = '/chat';
  final String userId; // This is the instructor's ID

  const Chat({
    required this.userId,
  });

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> messages = []; // Store messages here

  @override
  void initState() {
    super.initState();
    // Listen to all messages related to the instructor
    FirebaseFirestore.instance
        .collection('chats')
        .where('instructorId',
            isEqualTo: widget.userId) // Only check instructorId
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        messages = snapshot.docs; // Update the messages list on data change
      });
    });
  }

  void sendMessage(String message, String senderType) {
    if (message.trim().isEmpty) return;

    // Send the message with a sender field
    FirebaseFirestore.instance.collection('chats').add({
      'instructorId': widget.userId, // Link the message to the instructor
      'message': message,
      'sender': senderType, // Either 'instructor' or 'member'
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear(); // Clear input field after sending the message
    _scrollToBottom(); // Scroll to the bottom after sending
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              reverse: true, // Show the latest message at the bottom
              children: messages.map((doc) {
                final messageData = doc.data() as Map<String, dynamic>?;

                // Use null-aware operator to handle potential nulls
                final messageText =
                    messageData?['message'] ?? 'Invalid message';
                final sender =
                    messageData?['sender'] ?? 'member'; // Default to member

                // Determine the styling based on the sender
                final isInstructorMessage =
                    sender == 'instructor'; // Check if sender is instructor
                return Align(
                  alignment: isInstructorMessage
                      ? Alignment
                          .centerRight // Instructor messages on the right
                      : Alignment.centerLeft, // Member messages on the left
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isInstructorMessage
                          ? Colors.blue[200]
                          : Colors.green[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      messageText,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (message) {
                      sendMessage(
                          message, 'instructor'); // Send message as instructor
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_messageController.text,
                        'instructor'); // Send message as instructor
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
