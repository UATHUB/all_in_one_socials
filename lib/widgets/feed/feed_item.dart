import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  void like() async {
    final postId = widget.postId;
    setState(() {
      isLoading =
          true; // Tuşları kısıtlamak için fonksiyonun başladığını göster
    });

    final userDoc = FirebaseFirestore.instance //
        .collection('users') //  Kullanıcı Dosyasına Erişim
        .doc(FirebaseAuth.instance.currentUser!.uid); //

    DocumentSnapshot ds =
        await userDoc.get(); // Kullanıcı dosyasının güncel halini al
    List currentList = ds['liked']; // Alınan dosyadan liked listesini çek

    bool isLiked = currentList.contains(
        postId); //Post Idsi halihazırda liked listesinin içinde mi kontrol et

    if (isLiked) {
      currentList.remove(
          postId); //Eğer halihazırda like atılmışsa demek ki kullanıcı kaldırmak istiyor. Kaldır
    } else {
      currentList.add(
          postId); //Eğer daha önceden like atılmamışsa kullancı like atmak istiyor. At
    }

    List dislikedList = ds[
        'disliked']; // Like tuşuna basılması her durumda posttaki dislike ı kaldırmalı

    if (dislikedList.contains(postId)) {
      dislikedList.remove(postId);
    }

    isLiked = true;

    await userDoc.update({
      'liked': currentList,
      'disliked': dislikedList
    }); //Düzenlenen dosyayı karşıya geri yükle

    setState(() {
      isCurrentlyLiked(); //Dosyayı tekrar okut
      isLoading = false; //Fonksiyon bitişini göster
    });
  }

  void dislike() async {
    final postId = widget.postId;
    setState(() {
      isLoading =
          true; // Tuşları kısıtlamak için fonksiyonun başladığını göster
    });

    final userDoc = FirebaseFirestore.instance //
        .collection('users') //  Kullanıcı Dosyasına Erişim
        .doc(FirebaseAuth.instance.currentUser!.uid); //

    DocumentSnapshot ds =
        await userDoc.get(); // Kullanıcı dosyasının güncel halini al
    List currentList = ds['disliked']; // Alınan dosyadan liked listesini çek

    bool isDisliked = currentList.contains(
        postId); //Post Idsi halihazırda liked listesinin içinde mi kontrol et

    if (isDisliked) {
      currentList.remove(
          postId); //Eğer halihazırda like atılmışsa demek ki kullanıcı kaldırmak istiyor. Kaldır
    } else {
      currentList.add(
          postId); //Eğer daha önceden like atılmamışsa kullancı like atmak istiyor. At
    }
    List likedList = ds[
        'liked']; // Dislike tuşuna basılması her durumda posttaki like ı kaldırmalı

    if (likedList.contains(postId)) {
      likedList.remove(postId);
    }

    isDisliked = true;

    await userDoc.update({
      'liked': likedList,
      'disliked': currentList
    }); //Düzenlenen dosyayı karşıya geri yükle

    setState(() {
      isCurrentlyLiked(); //Dosyayı tekrar okut
      isLoading = false; //Fonksiyon bitişini göster
    });
  }

  void isCurrentlyLiked() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    DocumentSnapshot ds = await ref.get();
    List currentLikes = ds['liked'];

    await Future.delayed(Duration(seconds: 1));

    if (currentLikes.isEmpty) {
      isLiked = false;
      isDisliked = false;
      return;
    }

    if (currentLikes.contains(widget.postId)) {
      isLiked = true;
    } else {
      isDisliked = false;
    }
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  void initState() {
    isLiked = false;
    isDisliked = false;
    isCurrentlyLiked();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isCurrentlyLiked();
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
                        dislike();
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
                          like();
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
