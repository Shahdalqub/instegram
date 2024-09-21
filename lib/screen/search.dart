import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instegram/screen/chatui/chat.dart';
import 'package:instegram/screen/profile.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {});
                },
                controller: searchController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'search',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .where('username', isEqualTo: searchController.text)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return CircularProgressIndicator();
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> usermap =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return ListTile(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => Profile(
                                            userid: snapshot.data!.docs[index]
                                                ['uid'])));
                              },
                              title: Text(
                                snapshot.data!.docs[index]['username'],
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => Chat(
                                                  username: usermap['username'],
                                                  userimage:
                                                      usermap['userimage'],
                                                  uid: usermap['uid'],
                                                )));
                                  },
                                  icon: Icon(Icons.messenger_outline_sharp)),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                    snapshot.data!.docs[index]['userimage']),
                              ),
                            );
                          });
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
