import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instegram/screen/postScreen.dart';
import 'package:instegram/screen/profile.dart';
import 'package:instegram/screen/search.dart';

import 'home.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int selected = 0;
  void selectPage(int index) {
    setState(() {
      selected = index;
    });
  }

  final List pageList = [
    Home(),
    Search(),
    AddPost(),
    Profile(
      userid: FirebaseAuth.instance.currentUser!.uid,
    )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageList[selected],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selected,
        onTap: selectPage,
        fixedColor: Colors.white,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 26,
                color: Colors.white,
              ),
              label: 'home',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 26,
                color: Colors.white,
              ),
              label: 'search',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add,
                size: 26,
                color: Colors.white,
              ),
              label: 'add post',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 26,
                color: Colors.white,
              ),
              label: 'profile',
              backgroundColor: Colors.black)
        ],
      ),
    );
  }
}
