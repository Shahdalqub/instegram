import 'package:flutter/material.dart';
import 'package:instegram/firebase/firestore.dart';
import 'package:instegram/models/usermodel.dart';

class UserProvider with ChangeNotifier {
  UserModel? userdata;

  UserModel? get getuser {
    return userdata;
  }

  void fetchuser({required userid}) async {
    UserModel user = await FireStoreMethod().userdetailes(userid: userid);
    userdata = user;
    notifyListeners();
  }

  void increase_followers() {
    getuser!.followers.length++;
    notifyListeners();
  }

  void decrease_followers() {
    getuser!.followers.length--;
    notifyListeners();
  }
}
