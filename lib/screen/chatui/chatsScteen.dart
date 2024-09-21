import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instegram/screen/chatui/chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Chats',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('participants',
                  arrayContains: FirebaseAuth.instance.currentUser!.uid)
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  Map<String, dynamic> chatmap =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  String currentid = FirebaseAuth.instance.currentUser!.uid;
                  String name = currentid == chatmap['senderid']
                      ? chatmap['recivername']
                      : chatmap['sendername'];
                  String userimage = currentid == chatmap['senderid']
                      ? chatmap['reciverimage']
                      : chatmap['senderimage'];
                  String uid = currentid == chatmap['senderid']
                      ? chatmap['reciverid']
                      : chatmap['senderid'];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Chat(
                                  username: name,
                                  uid: uid,
                                  userimage: userimage,
                                )));
                      },
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('hello'),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(userimage),
                      ),
                      trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (String choice) {
                            if (choice == 'option1') {
                            } else if (choice == 'option2') {}
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'option1',
                                child: Text('delete'),
                              ),
                              PopupMenuItem<String>(
                                value: 'option2',
                                child: Text('Block'),
                              )
                            ];
                          }),
                    ),
                  );
                });
          }),
    );
  }
}
