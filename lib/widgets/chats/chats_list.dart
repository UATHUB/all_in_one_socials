import 'package:all_in_one_socials/widgets/chats/chat_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  var userData;
  var currentChat;
  getUserData(String userId) async {
    userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No chats found'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }
        List userChats = snapshot.data!['chats'];

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          itemCount: userChats.length,
          itemBuilder: (ctx, index) {
            final currentChatRef = userChats[index];
            final chatId = currentChatRef.id;

            return FutureBuilder<DocumentSnapshot>(
              future: currentChatRef.get(),
              builder: (context, chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final currentChat =
                    chatSnapshot.data?.data() as Map<String, dynamic>;

                String showingUserId;
                final startedUserId = currentChat['startedUserId'];
                final secondUserId = currentChat['otherUserId'];

                if (startedUserId == FirebaseAuth.instance.currentUser!.uid) {
                  showingUserId = secondUserId;
                } else {
                  showingUserId = startedUserId;
                }

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(showingUserId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final userData =
                        userSnapshot.data?.data() as Map<String, dynamic>;

                    final List messages = currentChat['messages'];

                    String lastMessage = '';
                    // Check if the messages list is empty
                    if (messages.isEmpty) {
                      lastMessage = 'Say Hi';
                    }
                    if (messages.isNotEmpty) {
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('messages')
                            .doc(messages.last.toString())
                            .get(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          final messageData = snapshot.data.data();

                          return ChatItem(
                            lastMessage: messageData['text'],
                            userImageUrl: userData['image_url'],
                            username: userData['username'],
                            chatId: chatId,
                          );
                        },
                      );
                    }

                    return ChatItem(
                      lastMessage: lastMessage,
                      userImageUrl: userData['image_url'],
                      username: userData['username'],
                      chatId: chatId,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
