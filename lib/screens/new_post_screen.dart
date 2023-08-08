import 'dart:io';

import 'package:all_in_one_socials/controllers/email_checker.dart';
import 'package:all_in_one_socials/screens/tabs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

UserDataController udc = Get.put(UserDataController());

final currentUser = FirebaseAuth.instance.currentUser;
final userData = udc.userData;
String enteredText = '';
bool hasPicture = false;
String pictureUrl = '';
bool loading = false;

class _NewPostScreenState extends State<NewPostScreen> {
  final _formkey = GlobalKey<FormState>();
  void submit() async {
    setState(() {
      loading = true;
    });

    _formkey.currentState!.save();

    final postReference =
        await FirebaseFirestore.instance.collection('posts').add({
      'text': enteredText,
      'createdAt': Timestamp.now(),
      'userId': currentUser!.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
      'hasPicture': hasPicture,
      'pictureUrl': hasPicture ? pictureUrl : null,
      'liked': [],
      'disliked': [],
    });

    final documentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    DocumentSnapshot ds = await documentRef.get();
    List currentList = ds['posts'];
    currentList.add(postReference);
    await documentRef.update({'posts': currentList});
    setState(() {
      loading = false;
      Get.close(1);
    });
  }

  void pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);

    if (pickedImage == null) {
      return;
    }
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('${currentUser!.uid}.jpg');

    await storageRef.putFile(File(pickedImage.path));
    pictureUrl = await storageRef.getDownloadURL();
    setState(() {
      hasPicture = true;
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
        'New Post',
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
                        labelText: 'What is on your mind',
                        labelStyle:
                            GoogleFonts.lato(color: cp.secondaryContainer)),
                  ),
                ),
                !hasPicture
                    ? IconButton(
                        onPressed: pickImage,
                        icon: Icon(
                          Icons.add_photo_alternate,
                          color: cp.secondaryContainer,
                        ))
                    : IconButton(
                        icon: Icon(
                          Icons.add_task,
                          color: cp.secondaryContainer,
                        ),
                        onPressed: pickImage,
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
