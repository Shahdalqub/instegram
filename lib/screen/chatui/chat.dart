import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instegram/provider/userprovider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Chat extends StatefulWidget {
  final String username;
  final String userimage;
  final String uid;
  const Chat(
      {super.key,
      required this.username,
      required this.userimage,
      required this.uid});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final textcont = TextEditingController();
  String chatroomid() {
    List users = [FirebaseAuth.instance.currentUser!.uid, widget.uid];
    users.sort();
    return '${users[0]}_${users[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.userimage),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.username,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatroomid())
                    .collection('messages')
                    .orderBy('date', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return CircularProgressIndicator();
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> messagemap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        String currentid =
                            FirebaseAuth.instance.currentUser!.uid;
                        String senderid = messagemap['senderid'];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                              alignment: currentid == senderid
                                  ? Alignment.topLeft
                                  : Alignment.topRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onLongPress: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('are you sure?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {},
                                                    child: Text('yes')),
                                                TextButton(
                                                    onPressed: () {},
                                                    child: Text('No')),
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          messagemap['message'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      width: 140,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: currentid == senderid
                                              ? Colors.black
                                              : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border:
                                              Border.all(color: Colors.grey)),
                                    ),
                                  ),
                                  Text(DateFormat.jm()
                                      .format(messagemap['date'].toDate()))
                                ],
                              )),
                        );
                      });
                }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  controller: textcont,
                  decoration: InputDecoration(
                    prefix: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.photo),
                      iconSize: 30,
                    ),
                    suffix: IconButton(
                        onPressed: () async {
                          final uuid = Uuid().v4();
                          if (textcont.text != '') {
                            await FirebaseFirestore.instance
                                .collection('chats')
                                .doc(chatroomid())
                                .set({
                              'sendername': userprovider.getuser!.username,
                              'senderimage': userprovider.getuser!.userimage,
                              'senderid': userprovider.getuser!.uid,
                              'recivername': widget.username,
                              'reciverimage': widget.userimage,
                              'reciverid': widget.uid,
                              'participants': [
                                userprovider.getuser!.uid,
                                widget.uid
                              ],
                              'chatroomid': chatroomid(),
                              'date': Timestamp.now()
                            });
                            await FirebaseFirestore.instance
                                .collection('chats')
                                .doc(chatroomid())
                                .collection('messages')
                                .doc(uuid)
                                .set({
                              'message': textcont.text,
                              'senderid': userprovider.getuser!.uid,
                              'date': Timestamp.now(),
                              'messageid': uuid
                            });
                          }
                          setState(() {
                            textcont.text = '';
                          });
                        },
                        icon: Icon(Icons.send)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Type here',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
