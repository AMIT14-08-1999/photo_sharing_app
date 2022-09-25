import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photosharing/home_screen/homeScreen.dart';
import 'package:photosharing/search_post/user.dart';
import 'package:photosharing/search_post/users_design.dart';

class SearchPost extends StatefulWidget {
  SearchPost({Key? key}) : super(key: key);

  @override
  State<SearchPost> createState() => _SearchPostState();
}

class _SearchPostState extends State<SearchPost> {
  Future<QuerySnapshot>? postDocumentList;
  String userNameText = "";
  intiSearchingPost(String textEntered) {
    postDocumentList = FirebaseFirestore.instance
        .collection("users")
        .where("name", isGreaterThanOrEqualTo: textEntered)
        .get();
    setState(() {
      postDocumentList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.amber],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.2, 0.9],
            ),
          ),
        ),
        title: TextField(
          onChanged: (textEntered) {
            setState(() {
              userNameText = textEntered;
            });
            intiSearchingPost(textEntered);
          },
          decoration: InputDecoration(
            hintText: "Search Post Here..",
            hintStyle: GoogleFonts.aBeeZee(
              color: Colors.white,
            ),
            border: InputBorder.none,
            suffixIcon: IconButton(
              onPressed: () {
                intiSearchingPost(userNameText);
              },
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
            ),
            prefixIcon: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                );
              },
              icon: const Padding(
                padding: EdgeInsets.only(right: 12, bottom: 4),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: postDocumentList,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Users model = Users.fromJson(snapshot.data!.docs[index]
                        .data()! as Map<String, dynamic>);
                    return UsersDesign(
                      model: model,
                      context: context,
                    );
                  },
                )
              : const Center(
                  child: Text(
                    "No Record Exists",
                  ),
                );
        },
      ),
    );
  }
}
