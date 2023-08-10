import 'package:all_in_one_socials/screens/new_post_screen.dart';
import 'package:all_in_one_socials/widgets/feed/feed_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FollowedFeed extends StatefulWidget {
  const FollowedFeed({super.key});

  @override
  State<FollowedFeed> createState() => _FollowedFeedState();
}

class _FollowedFeedState extends State<FollowedFeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(const NewPostScreen()),
        label: const Text('Create New Post'),
        icon: const Icon(Icons.new_label),
      ),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/feed_bg.png'),
          fit: BoxFit.fill,
        )),
        child: const FeedList.followed(),
      ),
    );
  }
}
