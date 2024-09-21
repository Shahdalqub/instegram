import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instegram/models/usermodel.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethod {
  Future<UserModel> userdetailes({required userid}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(userid).get();
    return UserModel.convertsnaptomodel(snap);
  }

  addpost({required Map postmap}) async {
    if (postmap['likes'].contains(FirebaseAuth.instance.currentUser!.uid)) {
      await FirebaseFirestore.instance
          .collection('post')
          .doc(postmap['postid'])
          .update({
        'likes':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
    } else {
      await FirebaseFirestore.instance
          .collection('post')
          .doc(postmap['postid'])
          .update({
        'likes': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      });
    }
  }

  deletdpost({required Map postmap}) async {
    if (FirebaseAuth.instance.currentUser!.uid == postmap['uid']) {
      await FirebaseFirestore.instance
          .collection('post')
          .doc(postmap['postid'])
          .delete();
    }
  }

  addcomment(
      {required comment,
      required userimage,
      required uid,
      required postid,
      required username}) async {
    final uuid = Uuid().v4();
    await FirebaseFirestore.instance
        .collection('post')
        .doc(postid)
        .collection('comments')
        .doc(uuid)
        .set({
      'username': username,
      'comment': comment,
      'userimage': userimage,
      'uid': uid,
      'postid': postid,
      'commentid': uuid,
      'date': Timestamp.now()
    });
  }

  followuser({required userid}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'following': FieldValue.arrayUnion([userid])
    });
    await FirebaseFirestore.instance.collection('users').doc(userid).update({
      'followers':
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });
  }

  unfollowuser({required userid}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'following': FieldValue.arrayRemove([userid])
    });
    await FirebaseFirestore.instance.collection('users').doc(userid).update({
      'followers':
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
  }
}
