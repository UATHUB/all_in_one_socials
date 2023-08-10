import 'dart:io';

import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/controllers/email_checker.dart';
import 'package:all_in_one_socials/controllers/page_controller.dart';
import 'package:all_in_one_socials/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';

final _firebase = FirebaseAuth.instance;

class SignupScreen2 extends StatefulWidget {
  const SignupScreen2({super.key});

  @override
  State<SignupScreen2> createState() => _SignupScreen2State();
}

EmailChecker ec = Get.put(EmailChecker());
ColorPalette cp = Get.put(ColorPalette());
PagesController pc = Get.put(PagesController());

class _SignupScreen2State extends State<SignupScreen2> {
  final formkey = GlobalKey<FormState>();
  bool loading = false;
  File? selectedImage;
  String enteredUsername = '';

  void _submit() async {
    final bool isValid = formkey.currentState!.validate();

    if (!isValid) {
      return;
    }

    formkey.currentState!.save();

    if (selectedImage == null) {
      Get.snackbar('Error', 'Please select a profile picture');
      return;
    }

    final userDataRef = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: enteredUsername)
        .get();

    if (userDataRef.docs.isNotEmpty) {
      Get.snackbar(
          'Error', 'This username is already taken. Please try another one.');
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      final userId = _firebase.currentUser!.uid;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('$userId.jpg');

      await storageRef.putFile(selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': enteredUsername,
        'email': ec.email,
        'image_url': imageUrl,
        'followers': [],
        'following': [],
        'posts': [],
        'liked': [],
        'disliked': [],
        'commented': [],
      });
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Authentication Failed');
    }
    setState(() {
      loading = false;
    });
    pc.exitLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/login_bg.png"), fit: BoxFit.cover),
            ),
            alignment: Alignment.center,
            child: GlassmorphicContainer(
              width: 300,
              height: 300,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFffffff).withOpacity(0.1),
                    const Color(0xFFFFFFFF).withOpacity(0.12),
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
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 230,
                    child: Form(
                      key: formkey,
                      child: Column(
                        children: [
                          UserImagePicker(onPickImage: (pickedImage) {
                            selectedImage = pickedImage;
                          }),
                          TextFormField(
                            style: const TextStyle().copyWith(color: cp.text),
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person),
                                labelStyle: const TextStyle()
                                    .copyWith(color: cp.container),
                                labelText: 'Enter Your Username'),
                            keyboardType: TextInputType.visiblePassword,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a valid username';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredUsername = value!;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  loading
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => Get.close(1),
                              icon: Icon(
                                Icons.arrow_circle_left_rounded,
                                size: 40,
                                color: cp.container,
                              ),
                            ),
                            const SizedBox(width: 40),
                            IconButton(
                              onPressed: _submit,
                              icon: Icon(
                                Icons.arrow_circle_right_rounded,
                                color: cp.container,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
