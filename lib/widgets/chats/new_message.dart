import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({
    super.key,
    required this.chatId,
  });
  final String chatId;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus(); //klavyeyi kapatma
    _messageController.clear(); //mesaj kutusunu temizleme

    final currentUser = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final messageRef =
        await FirebaseFirestore.instance.collection('messages').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': currentUser.uid,
      'userName': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });

    final currentChat = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();
    final List chatMessagesList = currentChat.data()!['messages'];
    chatMessagesList.add(messageRef.id);
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({'messages': chatMessagesList});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: _submitMessage,
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
