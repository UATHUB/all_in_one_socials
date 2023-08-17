import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';

ColorPalette cp = Get.find();

class ChatItem extends StatelessWidget {
  const ChatItem(
      {super.key,
      required this.lastMessage,
      required this.userImageUrl,
      required this.username,
      required this.chatId});

  final String userImageUrl;
  final String username;
  final String lastMessage;

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: () => Get.to(ChatScreen(chatId: chatId,username: username,)),
        child: GlassmorphicContainer(
          width: 300,
          height: 50,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.12),
              ],
              stops: const [
                0.1,
                1
              ]),
          borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFffffff).withOpacity(0),
                const Color((0xFFFFFFFF)).withOpacity(0),
              ]),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(userImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                username,
                style: GoogleFonts.lato(color: cp.text),
              ),
              const Spacer(),
              Text(
                lastMessage,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: GoogleFonts.lato(color: cp.text),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
