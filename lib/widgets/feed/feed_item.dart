import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';

ColorPalette cp = Get.find();

class FeedItem extends StatefulWidget {
  const FeedItem.plain({
    super.key,
    required this.username,
    required this.userImageUrl,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.postId,
  })  : isPlain = true,
        pictureUrl = null;
  const FeedItem.pic({
    super.key,
    required this.username,
    required this.userImageUrl,
    required this.content,
    required this.pictureUrl,
    required this.createdAt,
    required this.userId,
    required this.postId,
  }) : isPlain = false;

  final String username;
  final String userImageUrl;
  final String content;
  final String? pictureUrl;
  final String createdAt;
  final String userId;
  final String postId;

  final bool isPlain;

  @override
  State<FeedItem> createState() => _FeedItemState();
}

bool isLiked = false;
bool isDisliked = false;
bool isLoading = false;

class _FeedItemState extends State<FeedItem> {
  void likePost() async {
    setState(() {
      isLoading = true;
    });
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    DocumentSnapshot ds = await ref.get();
    List currentLikes = ds['liked'];
    currentLikes.add(widget.postId);
    await ref.update({'liked': currentLikes});

    List currentDislikes = ds['disliked'];
    if (currentDislikes.contains(widget.postId)) {
      currentDislikes.remove(widget.postId);
      await ref.update({'disliked': currentDislikes});
    }

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });

    Get.snackbar('Successful', 'Post has been liked');
  }

  void dislikePost() async {
    setState(() {
      isLoading = true;
    });
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    DocumentSnapshot ds = await ref.get();
    List currentDislikes = ds['disliked'];
    currentDislikes.add(widget.postId);
    await ref.update({'disliked': currentDislikes});

    List currentLikes = ds['liked'];
    if (currentLikes.contains(widget.postId)) {
      currentLikes.remove(widget.postId);
      await ref.update({'liked': currentLikes});
    }

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });

    Get.snackbar('Successful', 'Post has been disliked');
  }

  void unlikePost() async {
    setState(() {
      isLoading = true;
    });
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    DocumentSnapshot ds = await ref.get();
    List currentLikes = ds['liked'];
    currentLikes.remove(widget.postId);
    await ref.update({'liked': currentLikes});

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });

    Get.snackbar('Successful', 'Post has been unliked');
  }

  void undislikePost() async {
    setState(() {
      isLoading = true;
    });
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    DocumentSnapshot ds = await ref.get();
    List currentDislikes = ds['disliked'];
    currentDislikes.remove(widget.postId);
    await ref.update({'disliked': currentDislikes});

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });

    Get.snackbar('Successful', 'Post has been undisliked');
  }

  void isCurrentlyLiked() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    DocumentSnapshot ds = await ref.get();
    List currentLikes = ds['liked'];

    if (currentLikes.isEmpty) {
      isLiked = false;
      return;
    }

    if (currentLikes.contains(widget.postId)) {
      isLiked = true;
    } else {
      isLiked = false;
    }
  }

  void isCurrentlyDisliked() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    DocumentSnapshot ds = await ref.get();
    List currentDislikes = ds['disliked'];

    if (currentDislikes.isEmpty) {
      isDisliked = false;
      return;
    }

    if (currentDislikes.contains(widget.postId)) {
      isDisliked = true;
    } else {
      isDisliked = false;
    }
  }

  @override
  void initState() {
    isCurrentlyLiked();
    isCurrentlyDisliked();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isCurrentlyLiked();
    isCurrentlyDisliked();
    if (widget.isPlain) {
      return GlassmorphicContainer(
        width: 300,
        height: 150,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Get.to(ProfileScreen(userId: widget.userId)),
                  child: CircleAvatar(
                    foregroundImage: NetworkImage(widget.userImageUrl),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.username,
                  style: GoogleFonts.lato(color: cp.text),
                ),
                const Spacer(),
                if (isLoading) const CircularProgressIndicator(),
                if (!isLoading)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (isLiked) {
                          dislikePost();
                          return;
                        } else {
                          undislikePost();
                          return;
                        }
                      });
                    },
                    icon: isDisliked
                        ? const Icon(
                            Icons.thumb_down,
                            size: 25,
                          )
                        : const Icon(
                            Icons.thumb_down_alt_outlined,
                            size: 25,
                          ),
                  ),
                if (!isLoading)
                  IconButton(
                      onPressed: () {
                        setState(() {
                          if (isLiked) {
                            print('beğenilmiş');
                            unlikePost();
                            return;
                          } else {
                            likePost();
                            return;
                          }
                        });
                      },
                      icon: isLiked
                          ? const Icon(
                              Icons.thumb_up,
                              size: 25,
                            )
                          : const Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 25,
                            ))
              ],
            ),
            Text(
              widget.content,
              style: GoogleFonts.lato(color: cp.text),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      );
    } else {
      return GlassmorphicContainer(
        width: 300,
        height: 200,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                          onTap: () {
                            Get.to(ProfileScreen(userId: widget.userId));
                          },
                          child: CircleAvatar(
                              foregroundImage:
                                  NetworkImage(widget.userImageUrl))),
                      const SizedBox(width: 10),
                      Text(
                        widget.username,
                        style: GoogleFonts.lato(color: cp.text),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    width: 200,
                    height: 100,
                    child: Text(
                      widget.content,
                      style: GoogleFonts.lato(color: cp.text),
                    ),
                  ),
                ],
              ),
            ),
            Image.network(widget.pictureUrl!, height: 200),
          ],
        ),
      );
    }
  }
}
