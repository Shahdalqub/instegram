import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instegram/models/usermodel.dart';
import 'package:instegram/screen/bottombar.dart';
import 'package:instegram/screen/login.dart';
import 'package:uuid/uuid.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    name.dispose();
    password.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void signUp_method() async {
    setState(() {
      isLoading = true;
    });
    try {
      final uuid = Uuid().v4();
      final rref = FirebaseStorage.instance
          .ref()
          .child('usersImage')
          .child(uuid + 'jpg');
      await rref.putFile(pickedimage!);
      final imageurl = await rref.getDownloadURL();

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);
      UserModel user = UserModel(password.text, email.text, name.text, imageurl,
          FirebaseAuth.instance.currentUser!.uid, [], []);
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(user.converttomap());
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return Bottombar();
      }));
      setState(() {
        isLoading = false;
      });
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  final formKey = GlobalKey<FormState>();
  File? pickedimage;

  void selectimage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      var selected = File(image!.path);
      setState(() {
        pickedimage = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                  height: h * 0.1,
                ),
                Text("Insta app",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(
                  height: h * 0.05,
                ),
                Stack(
                  children: [
                    pickedimage != null
                        ? CircleAvatar(
                            radius: 30,
                            backgroundImage: FileImage(pickedimage!),
                          )
                        : CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                                'https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png'),
                          ),
                    Positioned(
                        top: 25,
                        left: 25,
                        child: IconButton(
                          color: Colors.grey,
                          onPressed: () {
                            selectimage();
                          },
                          icon: Icon(Icons.add),
                        ))
                  ],
                ),
                SizedBox(
                  height: h * 0.05,
                ),
                Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) return 'please inter your name';
                          },
                          decoration: InputDecoration(
                            hintText: 'name',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                          controller: name,
                        ),
                        SizedBox(
                          height: h * 0.03,
                        ),
                        TextFormField(
                          controller: email,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@'))
                              return 'please inter valid Email';
                          },
                          decoration: InputDecoration(
                            hintText: 'Email',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                        SizedBox(
                          height: h * 0.03,
                        ),
                        TextFormField(
                          controller: password,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7)
                              return 'please inter valid password';
                          },
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.visibility_off),
                            hintText: 'password',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  height: h * 0.05,
                ),
                SizedBox(
                    height: h * 0.05,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          formKey.currentState!.save();
                          if (formKey.currentState!.validate()) {
                            signUp_method();
                            //sign up in firebase
                          }
                        },
                        child: isLoading == true
                            ? CircularProgressIndicator()
                            : Text('sign up'))),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return LogIn();
                    }));
                  },
                  child: Text('do you have an account?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
