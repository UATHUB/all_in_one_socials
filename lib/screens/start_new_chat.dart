import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/controllers/email_checker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class StartNewChat extends StatefulWidget {
  const StartNewChat({super.key});

  @override
  State<StartNewChat> createState() => _StartNewChatState();
}

UserDataController udc = Get.find();
ColorPalette cp = Get.find();

final currentUser = FirebaseAuth.instance.currentUser;
final userData = udc.userData;
String enteredText = '';
bool hasPicture = false;
String pictureUrl = '';
bool loading = false;

class _StartNewChatState extends State<StartNewChat> {
  final _formkey = GlobalKey<FormState>();

  void submit() async {
    setState(() {
      loading = true;
    });
    _formkey.currentState!.save();

    final usernameExistsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: enteredText)
        .get();

    if (usernameExistsSnapshot.docs.isNotEmpty) {
      final enteredUserData = usernameExistsSnapshot.docs.first;
      final enteredUserId = enteredUserData.id;

      final currentUserData = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      final chatId = currentUserData.data()!['username'] +
          '--' +
          enteredUserData.data()['username'];

      final chatReference =
          await FirebaseFirestore.instance.collection('chats').add({
        'chatId': chatId,
        'startedUserId': currentUser!.uid,
        'startedUserImageUrl': currentUserData['image_url'],
        'otherUserId': enteredUserId,
        'otherUserImageUrl': enteredUserData['image_url'],
        'messages': [],
        'media': [],
        'lastChanged': Timestamp.now(),
      });

      List currentUserChats = await currentUserData.data()!['chats'];
      List enteredUserChats = await enteredUserData.data()['chats'];

      currentUserChats.add(chatReference);
      enteredUserChats.add(chatReference);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'chats': currentUserChats});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(enteredUserId)
          .update({'chats': enteredUserChats});
      Get.snackbar('Successful', 'New chat has been created. Say hi!');
      Get.close(1);
    } else {
      Get.snackbar('Error', 'Username does not exsist');
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    enteredText = '';
    hasPicture = false;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      titleTextStyle: GoogleFonts.lato(
          color: cp.text, fontWeight: FontWeight.w600, fontSize: 16),
      title: const Text(
        'New Chat',
        textAlign: TextAlign.center,
      ),
      alignment: Alignment.center,
      backgroundColor: cp.bg,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formkey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: GoogleFonts.lato(color: cp.text),
                    onSaved: (value) {
                      if (value == null) {
                        return;
                      }
                      enteredText = value;
                    },
                    decoration: InputDecoration(
                        labelText: 'Enter username to start chatting',
                        labelStyle:
                            GoogleFonts.lato(color: cp.secondaryContainer)),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading
            ? const CircularProgressIndicator()
            : IconButton(
                onPressed: submit,
                icon: Icon(
                  Icons.send,
                  color: cp.secondaryContainer,
                ))
      ],
    );
  }
}
