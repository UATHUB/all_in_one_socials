// import 'package:all_in_one_socials/controllers/color_palette.dart';
// import 'package:all_in_one_socials/screens/all_chats.dart';
// import 'package:all_in_one_socials/screens/all_feed.dart';
// import 'package:all_in_one_socials/screens/followed_feed.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class Tabs extends StatefulWidget {
//   const Tabs({super.key});

//   @override
//   State<Tabs> createState() => _TabsState();
// }
//  late Future<String> imageUrlFuture;
// ColorPalette cp = Get.put(ColorPalette());
// String picUrl = '';
// final _firebase = FirebaseAuth.instance;
// final _tabs = [const FollowedFeed(), const AllChatsScreen(), const AllFeed()];
// final _tabsList = [
//   const Tab(
//     text: 'Followed',
//     icon: Icon(Icons.chair_rounded),
//   ),
//   const Tab(
//     text: 'Your Chats',
//     icon: Icon(Icons.message),
//   ),
//   const Tab(
//     text: 'All Feed',
//     icon: Icon(Icons.fireplace),
//   )
// ];

// void getData() async {
//   final userData = await FirebaseFirestore.instance
//       .collection('users')
//       .doc(_firebase.currentUser!.uid)
//       .get();

//   if (userData.data() == null) {}

//   picUrl = userData.data()!['image_url'];
// }

// String getImage() {
//   getData();
//   print(picUrl);
//   return picUrl;
// }

// class _TabsState extends State<Tabs> {,
// @override
//   void initState() {
//     super.initState();
//     imageUrlFuture=picUrl;
//   }
//   @override
//   Widget build(BuildContext context) {

//     return DefaultTabController(
//       length: _tabs.length,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: cp.container,
//           title: Text(
//             'All In One Socials',
//             style: const TextStyle().copyWith(color: cp.text),
//           ),
//           centerTitle: true,
//           leading: GestureDetector(
//             onLongPress: () => _firebase.signOut(),
//             child: FutureBuilder<String>(
//               future: imageUrlFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   // While waiting for the data to be fetched, show a placeholder.
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   // If an error occurs during data fetching, handle it accordingly.
//                   return Icon(Icons.error);
//                 } else {
//                   // If the data is available, use the URL to display the image.
//                   return Container(
//                     height: 10,
//                     width: 10,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       image: DecorationImage(
//                         alignment: Alignment.center,
//                         fit: BoxFit.cover,
//                         image: NetworkImage(snapshot.data ?? ''),
//                       ),
//                     ),
//                   );
//                 }
//               },
//           ),
//           bottom: TabBar(
//             tabs: _tabsList,
//             unselectedLabelColor: cp.secondaryContainer,
//             labelColor: cp.text,
//           ),
//         ),
//         body: TabBarView(children: _tabs),
//       ),
//     );
//   }
// }
import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/controllers/email_checker.dart';
import 'package:all_in_one_socials/screens/all_chats.dart';
import 'package:all_in_one_socials/screens/all_feed.dart';
import 'package:all_in_one_socials/screens/followed_feed.dart';
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

  @override
  void initState() {
    super.initState();
    imageUrlFuture = getData();
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

    return ''; // Return a default URL or empty string if data is not available.
  }

  @override
  Widget build(BuildContext context) {
    final username = getUsername();
    return DefaultTabController(
      initialIndex: 1,
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: cp.container,
          title: Text(
            "'s Socials",
            style: const TextStyle().copyWith(color: cp.text),
          ),
          centerTitle: true,
          leading: GestureDetector(
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
