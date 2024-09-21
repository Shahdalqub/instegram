import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../provider/userprovider.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  @override
  File? pickedimage;
  final des = TextEditingController();

  void selectimage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      var selected = File(image!.path);
      setState(() {
        pickedimage = selected;
      });
    }
  }

  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);
    void uploadPost() async {
      try {
        final uuid = Uuid().v4();
        final rref = FirebaseStorage.instance
            .ref()
            .child('PostImage')
            .child(uuid + 'jpg');
        await rref.putFile(pickedimage!);
        final imageurl = await rref.getDownloadURL();

        FirebaseFirestore.instance.collection('post').doc(uuid).set({
          'username': userprovider.getuser!.username,
          'uid': userprovider.getuser!.uid,
          'userimage': userprovider.getuser!.userimage,
          'imagepost': imageurl,
          'postid': uuid,
          'des': des.text,
          'likes': [],
          'date': Timestamp.now()
        });
        setState(() {
          pickedimage = null;
          des.text = '';
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('done')));
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            pickedimage = null;
                            des.text = '';
                          });
                        },
                        icon: Icon(
                          Icons.cancel,
                          size: 26,
                        )),
                    Text(
                      'New Post',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                        onPressed: () {
                          uploadPost();
                        },
                        child: Text(
                          'Next  ',
                          style: TextStyle(fontSize: 22),
                        ))
                  ],
                ),
                pickedimage == null
                    ? SizedBox(
                        height: h * 0.4,
                      )
                    : Image.file(
                        pickedimage!,
                        height: h * 0.4,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                IconButton(
                    onPressed: () {
                      selectimage();
                    },
                    icon: Icon(
                      Icons.upload,
                      size: 28,
                    )),
                TextField(
                  controller: des,
                  maxLines: 15,
                  decoration: InputDecoration(
                      hintText: 'add comment',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
