import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instegram/firebase/firestore.dart';
import 'package:instegram/screen/comment.dart';
import 'package:intl/intl.dart';

class Post extends StatelessWidget {
  final Map<String, dynamic> postmap;
  const Post({super.key, required this.postmap});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(postmap['userimage']),
                ),
                SizedBox(
                  width: w * 0.05,
                ),
                Text(
                  postmap['username'],
                  style: TextStyle(fontSize: 22),
                ),
                Spacer(),
                IconButton(
                    onPressed: () {
                      FireStoreMethod().deletdpost(postmap: postmap);
                    },
                    icon: Icon(Icons.delete))
              ],
            ),
          ),
          Image.network(
            postmap['imagepost'],
            height: h * 0.5,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    FireStoreMethod().addpost(postmap: postmap);
                  },
                  icon: Icon(
                    Icons.favorite,
                    color: postmap['likes']
                            .contains(FirebaseAuth.instance.currentUser!.uid)
                        ? Colors.red
                        : Colors.white,
                  )),
              IconButton(onPressed: () {}, icon: Icon(Icons.comment)),
            ],
          ),
          Text(
            '${postmap['likes'].length} likes',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            postmap['des'],
            style: TextStyle(fontSize: 18),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Comment(
                    postid: postmap['postid'],
                  );
                }));
              },
              child: Text(
                'add comment',
                style: TextStyle(color: Colors.grey),
              )),
          Text(
            DateFormat.jm().format(postmap['date'].toDate()),
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}
