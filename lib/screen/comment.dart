import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instegram/firebase/firestore.dart';
import 'package:instegram/provider/userprovider.dart';
import 'package:provider/provider.dart';

class Comment extends StatefulWidget {
  final String postid;
  const Comment({super.key, required this.postid});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final comment = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Comment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('post')
                    .doc(widget.postid)
                    .collection('comments')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return CircularProgressIndicator();
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> commentmap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        return ListTile(
                          title: Text(commentmap['username']),
                          subtitle: Text(commentmap['comment']),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(commentmap['userimage']),
                          ),
                          trailing: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.favorite),
                          ),
                        );
                      });
                }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        NetworkImage(userprovider.getuser!.userimage),
                  ),
                  Expanded(
                    child: TextField(
                      controller: comment,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                if (comment.text != '') {
                                  FireStoreMethod().addcomment(
                                      username: userprovider.getuser!.username,
                                      comment: comment.text,
                                      userimage:
                                          userprovider.getuser!.userimage,
                                      uid: userprovider.getuser!.uid,
                                      postid: widget.postid);
                                }
                                comment.text = '';
                              },
                              icon: Icon(Icons.send)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue)),
                          hintText: 'add comment',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
