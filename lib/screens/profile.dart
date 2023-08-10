import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/widgets/feed/feed_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

ColorPalette cp = Get.find();

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  late bool isMe;
  late bool isFollowing;

  String username = '';
  String userPictureUrl = '';
  List followers = [];
  List following = [];
  List posts = [];

  void checkIsMe() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    if (currentUserId == widget.userId) {
      isMe = true;
    } else {
      isMe = false;
    }
  }

  void checkFollowing() {
    setState(() {
      super.setState(() {});
      if (followers.contains(FirebaseAuth.instance.currentUser!.uid)) {
        isFollowing = true;
      } else {
        isFollowing = false;
      }
    });
  }

  void follow() async {
    setState(() {
      isLoading = true;
    });

    final currentUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (currentUserData.data() == null) {
      return;
    }
    List currentFollowingList = currentUserData.data()!['following'];
    if (currentFollowingList.contains(widget.userId)) {
      currentFollowingList.remove(widget.userId);
      followers.remove(FirebaseAuth.instance.currentUser!.uid);
    } else {
      currentFollowingList.add(widget.userId);
      followers.add(FirebaseAuth.instance.currentUser!.uid);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'following': currentFollowingList});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'followers': followers});

    setState(() {
      isLoading = false;
    });
  }

  void getUserData() async {
    setState(() {
      isLoading = true;
    });
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userData.data() == null || userData.data()!.isEmpty) {
      Get.snackbar('Error', 'An error occured while fetching user data');
      return;
    }

    username = userData.data()!['username'];
    userPictureUrl = userData.data()!['image_url'];
    followers = userData.data()!['followers'];
    following = userData.data()!['following'];
    posts = userData.data()!['posts'];

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkIsMe();
    getUserData();
    if (!isMe) {
      checkFollowing();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: cp.bg,
          centerTitle: true,
          title: Text(username),
        ),
        body: Container(
          height: double.maxFinite,
          width: double.infinity,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: AssetImage('assets/feed_bg.png'))),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: GlassmorphicContainer(
                  width: 400,
                  height: 200,
                  borderRadius: 20,
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
                  border: 2,
                  blur: 20,
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
                      Container(
                        height: 250,
                        width: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(userPictureUrl),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              ElevatedButton(
                                onPressed: follow,
                                child: isFollowing
                                    ? const Text('Follow')
                                    : const Text('Unfollow'),
                              ),
                            Text(
                              'Followers : ${followers.length}',
                              style: GoogleFonts.lato(
                                  color: cp.text, fontSize: 20),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Following : ${following.length}',
                              style: GoogleFonts.lato(
                                  color: cp.text, fontSize: 20),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Posts : ${posts.length}',
                              style: GoogleFonts.lato(
                                  color: cp.text, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: GlassmorphicContainer(
                  width: 400,
                  height: 50,
                  borderRadius: 20,
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
                  border: 2,
                  blur: 20,
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFffffff).withOpacity(0),
                      const Color((0xFFFFFFFF)).withOpacity(0),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Posts',
                      style:
                          GoogleFonts.courgette(color: cp.text, fontSize: 30),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                height: MediaQuery.sizeOf(context).height - 370,
                child: FeedList.profile(profileId: widget.userId),
              ),
            ],
          ),
        ),
      );
    }
  }
}
