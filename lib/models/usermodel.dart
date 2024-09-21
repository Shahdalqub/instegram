import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String password, email, username, userimage, uid;
  final List followers;
  final List following;
  UserModel(this.password, this.email, this.username, this.userimage, this.uid,
      this.followers, this.following);

  Map<String, dynamic> converttomap() {
    return {
      'password': password,
      'email': email,
      'username': username,
      'userimage': userimage,
      'uid': uid,
      'followers': followers,
      'following': following,
    };
  }

  static convertsnaptomodel(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
        snapshot['password'],
        snapshot['email'],
        snapshot['username'],
        snapshot['userimage'],
        snapshot['uid'],
        snapshot['followers'],
        snapshot['following']);
  }
}
