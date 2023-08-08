import 'package:all_in_one_socials/screens/login_signup%20screens/email.dart';
import 'package:all_in_one_socials/screens/login_signup%20screens/login.dart';
import 'package:all_in_one_socials/screens/login_signup%20screens/signup.dart';
import 'package:all_in_one_socials/screens/login_signup%20screens/signup_2.dart';
import 'package:all_in_one_socials/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PagesController extends GetxController {
  List<Widget> pageList = [
    /*0*/ const EmailScreen(),
    /*1*/ const LoginScreen(),
    /*2*/ const SignupScreen(),
    /*3*/ const SignupScreen2(),
    /*4*/ const Tabs(),
  ];

  void changePage(int id) {
    Get.to(pageList[id], transition: Transition.rightToLeft);
  }

  void exitLogin() {
    Get.offAll(pageList[4]);
  }
}
