import 'package:all_in_one_socials/widgets/chats/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.chatId,
  });
  final String chatId;

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshots.hasData) {
          return const Center(
            child: Text('No messages found'),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        final List loadedMessagesIds = chatSnapshots.data!.data()!['messages'];
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: loadedMessagesIds.length,
          reverse: true,
          itemBuilder: (context, index) {
            final currentMessageId =
                loadedMessagesIds[loadedMessagesIds.length - index - 1];
            return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(currentMessageId)
                    .get(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final chatMessage = snapshot.data!.data();

                  return MessageBubble.next(
                    message: chatMessage!['text'],
                    isMe: authenticatedUser.uid == chatMessage['userId'],
                  );
                });
          },
        );

        // return ListView.builder(
        //   padding:
        //       const EdgeInsets.only(bottom: 40, left: 13, right: 13, top: 5),
        //   itemCount: loadedMessages.length,
        //   reverse: true,
        //   itemBuilder: (ctx, index) {
        //     final chatMessage = loadedMessages[index];
        //     final nextChatMessage = index + 1 < loadedMessages.length
        //         ? loadedMessages[index + 1].data()
        //         : null;

        //     final currentMessageUserId = chatMessage['userId'];
        //     final nextMessageUserId =
        //         nextChatMessage != null ? nextChatMessage['userId'] : null;

        //     final bool nextUserIsSame =
        //         nextMessageUserId == currentMessageUserId;

        //     if (nextUserIsSame) {
        //       return MessageBubble.next(
        //         message: chatMessage['text'],
        //         isMe: authenticatedUser.uid == currentMessageUserId,
        //       );
        //     } else {
        //       return MessageBubble.first(
        //         userImage: chatMessage['userImage'],
        //         username: chatMessage['userName'],
        //         message: chatMessage['text'],
        //         isMe: authenticatedUser.uid == currentMessageUserId,
        //       );
        //     }
        //   },
        // );
      },
    );
  }
}
