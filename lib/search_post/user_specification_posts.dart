// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:photosharing/login/login_screen.dart';
import 'package:photosharing/owner_details/owner_details.dart';
import 'package:photosharing/profile_Screen/profile_screen.dart';
import 'package:photosharing/search_post/search_post.dart';

class UserSpecificationPosts extends StatefulWidget {
  String? userId;
  String? userName;
  UserSpecificationPosts({
    Key? key,
    this.userId,
    this.userName,
  }) : super(key: key);

  @override
  State<UserSpecificationPosts> createState() => _UserSpecificationPostsState();
}

class _UserSpecificationPostsState extends State<UserSpecificationPosts> {
  String? myImage;
  String? myName;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void read_userInfo() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
    });
  }

  @override
  void initState() {
    super.initState();
    read_userInfo();
  }

  Widget listViewWidget(
    String docId,
    String img,
    String userImg,
    String name,
    DateTime date,
    String userId,
    int downloads,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 10,
        shadowColor: Colors.white10,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.amber.shade100],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.2, 0.9],
            ),
          ),
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (c) => OwnerDetails(
                        img: img,
                        userImg: userImg,
                        name: name,
                        date: date,
                        docId: docId,
                        userId: userId,
                        downloads: downloads,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  img,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        userImg,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.alata(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          DateFormat("dd MMMM, yyyy-hh:mm a -> ")
                              .format(date)
                              .toString(),
                          style: GoogleFonts.alata(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.amber.shade100],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.amber],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9],
              ),
            ),
          ),
          title: Text(widget.userName!),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: const Icon(
              Icons.logout_outlined,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchPost(),
                  ),
                );
              },
              icon: const Icon(Icons.person_search),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("wallpaper")
              .where("id", isEqualTo: widget.userId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return listViewWidget(
                      snapshot.data!.docs[index].id,
                      snapshot.data!.docs[index]['image'],
                      snapshot.data!.docs[index]['userImage'],
                      snapshot.data!.docs[index]['name'],
                      snapshot.data!.docs[index]['createdAt'].toDate(),
                      snapshot.data!.docs[index]['id'],
                      snapshot.data!.docs[index]['downloads'],
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    "There is no tasks",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                );
              }
            }
            return const Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
