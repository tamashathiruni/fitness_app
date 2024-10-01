import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String instructorId;
  static const routeName = '/chat';

  const ChatScreen({required this.userId, required this.instructorId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;

    FirebaseFirestore.instance.collection('chats').add({
      'memberId': widget.userId,
      'instructorId': widget.instructorId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
    _scrollToBottom();
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('memberId', isEqualTo: widget.userId)
                  .where('instructorId', isEqualTo: widget.instructorId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                // Create a list of message widgets
                List<Widget> messageWidgets = messages.map((doc) {
                  // Access the data directly as Map<String, dynamic>
                  final messageData = doc.data();

                  // Check if messageData is a Map and contains the 'message' field
                  if (messageData is Map<String, dynamic> &&
                      messageData['message'] != null) {
                    final messageText = messageData['message'] as String;
                    return ListTile(
                      title: Text(messageText),
                    );
                  }

                  // Return a default message if the data is invalid
                  return ListTile(
                    title: Text('Invalid message'),
                  );
                }).toList();

                return ListView(
                  controller: _scrollController,
                  reverse: true,
                  children: messageWidgets, // Use the list of message widgets
                );
              },
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
                    onSubmitted: sendMessage,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_messageController.text);
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
