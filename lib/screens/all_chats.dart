import 'package:all_in_one_socials/screens/start_new_chat.dart';
import 'package:all_in_one_socials/widgets/chats/chats_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllChatsScreen extends StatefulWidget {
  const AllChatsScreen({super.key});

  @override
  State<AllChatsScreen> createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.dialog(const StartNewChat()),
        child: const Icon(Icons.new_label),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/feed_bg.png'),
          ),
        ),
        child: const ChatList(),
      ),
    );
  }
}
