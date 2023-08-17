import 'package:all_in_one_socials/screens/profile.dart';
import 'package:all_in_one_socials/widgets/chats/chat_messages.dart';
import 'package:all_in_one_socials/widgets/chats/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.username,
  });

  final String chatId;
  final String username;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var userData;

  void getUserData() async {
    userData = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.username)
        .get();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.username),
          actions: [
            IconButton(
              onPressed: () async {
                final userData = await FirebaseFirestore.instance
                    .collection('users')
                    .where('username', isEqualTo: widget.username)
                    .get();
               
                final userId = userData.docs.first.id;
                Get.to(ProfileScreen(userId: userId));
              },
              icon: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('username', isEqualTo: widget.username)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final urlData = snapshot.data!.docs.first;

                  return CircleAvatar(
                      foregroundImage:
                          NetworkImage(urlData.data()['image_url']));
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: ChatMessages(chatId: widget.chatId)),
            NewMessage(chatId: widget.chatId),
          ],
        ));
  }
}
