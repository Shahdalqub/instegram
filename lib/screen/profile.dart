import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instegram/firebase/firestore.dart';
import 'package:instegram/provider/userprovider.dart';
import 'package:instegram/screen/signup.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final String userid;
  const Profile({super.key, required this.userid});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late List following;
  late bool infollowing;
  bool isLoading = false;
  late int postcount = 0;
  void fetch_curr_user() async {
    setState(() {
      isLoading = true;
    });
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    following = snapshot.data()!['following'];
    setState(() {
      infollowing = following.contains(widget.userid);
      isLoading = false;
    });
    var snap = await FirebaseFirestore.instance
        .collection('post')
        .where('uid', isEqualTo: widget.userid)
        .get();
    postcount = snap.docs.length;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userprovider = Provider.of<UserProvider>(context, listen: false);
    userprovider.fetchuser(userid: widget.userid);
    fetch_curr_user();
  }

  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            widget.userid == FirebaseAuth.instance.currentUser!.uid
                ? IconButton(
                    onPressed: () async {
                      FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return SignUp();
                      }));
                    },
                    icon: Icon(Icons.login_outlined))
                : Text('')
          ],
        ),
        body: isLoading == true
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: h * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                            userprovider.getuser!.userimage,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              postcount.toString(),
                              style: TextStyle(fontSize: 18),
                            ),
                            Text('posts', style: TextStyle(fontSize: 18))
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${userprovider.getuser!.followers.length}',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text('followers', style: TextStyle(fontSize: 18))
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${userprovider.getuser!.following.length}',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text('following', style: TextStyle(fontSize: 18))
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${userprovider.getuser!.username}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: infollowing == true
                                    ? Colors.red
                                    : Colors.grey[900]),
                            onPressed: () {
                              if (infollowing == true) {
                                FireStoreMethod()
                                    .unfollowuser(userid: widget.userid);
                                userprovider.decrease_followers();
                                setState(() {
                                  infollowing = false;
                                });
                              } else {
                                setState(() {
                                  userprovider.increase_followers();
                                  infollowing = true;
                                });

                                FireStoreMethod()
                                    .followuser(userid: widget.userid);
                              }
                            },
                            child: (FirebaseAuth.instance.currentUser!.uid ==
                                    widget.userid)
                                ? Text('Edit profile')
                                : infollowing == true
                                    ? Text('UnFollow')
                                    : Text('Follow'))),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 3,
                    ),
                    FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('post')
                            .where('uid', isEqualTo: widget.userid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return CircularProgressIndicator();
                          if (snapshot.hasError) return Text('error');
                          return GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1,
                            childAspectRatio: 3.2 / 3,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(snapshot.data!.docs.length,
                                (index) {
                              return Image.network(
                                  snapshot.data!.docs[index]['imagepost']);
                            }),
                          );
                        }),
                  ],
                ),
              ),
      ),
    );
  }
}
