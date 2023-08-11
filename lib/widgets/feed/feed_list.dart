import 'package:all_in_one_socials/widgets/feed/feed_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedList extends StatefulWidget {
  const FeedList.general({super.key})
      : profileId = '',
        isProfile = false,
        isFollowed = false,
        isAll = true;
  const FeedList.profile({super.key, required this.profileId})
      : isProfile = true,
        isFollowed = false,
        isAll = false;
  const FeedList.followed({super.key})
      : profileId = '',
        isFollowed = true,
        isProfile = false,
        isAll = false;

  final bool isProfile;
  final bool isFollowed;
  final bool isAll;

  final String profileId;

  @override
  State<FeedList> createState() => _FeedListState();
}

List followedByUser = [];

class _FeedListState extends State<FeedList> {
  void createFollowingList() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    followedByUser = userData.data()!['following'];
  }

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

        var displayedPosts = [];

        if (widget.isProfile) {
          for (int i = 0; i < loadedPosts.length; i++) {
            if (loadedPosts[i].data()['userId'] == widget.profileId) {
              displayedPosts.add(loadedPosts[i]);
            }
          }
        }
        if (widget.isFollowed) {
          createFollowingList();

          for (int i = 0; i < loadedPosts.length; i++) {
            if (followedByUser.contains(loadedPosts[i].data()['userId'])) {
              displayedPosts.add(loadedPosts[i]);
            }
          }
        }
        if (widget.isAll) {
          displayedPosts = loadedPosts;
        }

        if (displayedPosts.isEmpty) {
          return const Center(
            child: Text('There is nothing to show...'),
          );
        }

        return ListView.builder(
            reverse: true,
            itemCount: displayedPosts.length,
            itemBuilder: (ctx, index) {
              final postId = displayedPosts[index].id;
              final post = displayedPosts[index].data();

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
