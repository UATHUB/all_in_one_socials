import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/controllers/email_checker.dart';
import 'package:all_in_one_socials/screens/all_chats.dart';
import 'package:all_in_one_socials/screens/all_feed.dart';
import 'package:all_in_one_socials/screens/followed_feed.dart';
import 'package:all_in_one_socials/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

ColorPalette cp = Get.put(ColorPalette());
UserDataController udc = Get.put(UserDataController());

final _firebase = FirebaseAuth.instance;
final _tabs = [const FollowedFeed(), const AllChatsScreen(), const AllFeed()];
final _tabsList = [
  const Tab(
    text: 'Followed',
    icon: Icon(Icons.chair_rounded),
  ),
  const Tab(
    text: 'Your Chats',
    icon: Icon(Icons.message),
  ),
  const Tab(
    text: 'All Feed',
    icon: Icon(Icons.fireplace),
  ),
];

class _TabsState extends State<Tabs> {
  late Future<String> imageUrlFuture;
  late Future<String> titleName;

  @override
  void initState() {
    super.initState();
    imageUrlFuture = getData();
    titleName = getUsername();
  }

  Future<String> getData() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebase.currentUser!.uid)
        .get();

    udc.userData = userData;

    if (userData.data() != null) {
      return userData.data()!['image_url'];
    }

    return ''; // Return a default URL or empty string if data is not available.
  }

  Future<String> getUsername() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebase.currentUser!.uid)
        .get();

    udc.userData = userData;

    if (userData.data() != null) {
      return userData.data()!['username'];
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: cp.bg,
          title: FutureBuilder<String>(
              future: titleName,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('There Was An Error');
                } else {
                  return Text("${snapshot.data}'s All Social");
                }
              }),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () =>
                Get.to(ProfileScreen(userId: _firebase.currentUser!.uid)),
            onLongPress: () => _firebase.signOut(),
            child: FutureBuilder<String>(
              future: imageUrlFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While waiting for the data to be fetched, show a placeholder.
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // If an error occurs during data fetching, handle it accordingly.
                  return const Icon(Icons.error);
                } else {
                  // If the data is available, use the URL to display the image.
                  return Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        image: NetworkImage(snapshot.data ?? ''),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          bottom: TabBar(
            tabs: _tabsList,
            unselectedLabelColor: cp.secondaryContainer,
            labelColor: cp.text,
          ),
        ),
        body: TabBarView(children: _tabs),
      ),
    );
  }
}
