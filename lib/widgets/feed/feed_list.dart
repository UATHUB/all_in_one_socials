import 'package:all_in_one_socials/widgets/feed/feed_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedList extends StatefulWidget {
  const FeedList({super.key});

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No posts found'),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        final loadedPosts = chatSnapshots.data!.docs;

        return ListView.builder(
            reverse: true,
            itemCount: loadedPosts.length,
            itemBuilder: (ctx, index) {
              final postId = loadedPosts[index].id;
              final post = loadedPosts[index].data();

              final postUsername = post['username'];
              final postUserImage = post['userImage'];
              final postContent = post['text'];
              final postHasPicture = post['hasPicture'];
              final postPictureUrl = post['pictureUrl'];
              final postCreatedAt = post['createdAt'].toString();
              final userId = post['userId'];

              if (postHasPicture) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: FeedItem.pic(
                    userId: userId,
                    username: postUsername,
                    userImageUrl: postUserImage,
                    content: postContent,
                    pictureUrl: postPictureUrl,
                    createdAt: postCreatedAt,
                    postId: postId,
                  ),
                );
              } else {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: FeedItem.plain(
                    userId: userId,
                    username: postUsername,
                    userImageUrl: postUserImage,
                    content: postContent,
                    createdAt: postCreatedAt,
                    postId: postId,
                  ),
                );
              }
            });
      },
    );
  }
}
