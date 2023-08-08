import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userId});

  final userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

ColorPalette cp = Get.find();

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(color: cp.bg),
        )
      ]),
    );
  }
}
