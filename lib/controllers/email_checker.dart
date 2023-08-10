import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EmailChecker extends GetxController {
  String email = '';
  List<String> list = [];
  bool checkRegistered(List list) {
    if (list.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

class UserDataController extends GetxController {
  late DocumentSnapshot<Map<String, dynamic>> userData;
}
