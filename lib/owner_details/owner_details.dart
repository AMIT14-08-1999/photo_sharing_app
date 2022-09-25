// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart';
import 'package:photosharing/home_screen/homeScreen.dart';
import 'package:photosharing/widgets/button_square.dart';

class OwnerDetails extends StatefulWidget {
  String? img;
  String? userImg;
  String? name;
  DateTime? date;
  String? docId;
  String? userId;
  int? downloads;

  OwnerDetails({
    Key? key,
    this.img,
    this.userImg,
    this.name,
    this.date,
    this.docId,
    this.userId,
    this.downloads,
  }) : super(key: key);

  @override
  State<OwnerDetails> createState() => _OwnerDetailsState();
}

class _OwnerDetailsState extends State<OwnerDetails> {
  int? total;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.amber.shade100],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.2, 0.9],
          ),
        ),
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  color: Colors.red,
                  child: Column(
                    children: [
                      Image.network(
                        widget.img!,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30.0),
                Text(
                  'Owner Information:- ',
                  style: GoogleFonts.acme(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30.0),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        widget.userImg!,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Text(
                  'Uploaded by :-  ${widget.name!}',
                  style: GoogleFonts.adamina(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  DateFormat("dd MMMM, yyyy - hh:mm a")
                      .format(widget.date!)
                      .toString(),
                  style: GoogleFonts.actor(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.download_outlined,
                      size: 40,
                      color: Colors.black,
                    ),
                    Text(
                      "${widget.downloads}",
                      style: GoogleFonts.adventPro(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50.0),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: ButtonSquare(
                    text: "Download",
                    press: () async {
                      try {
                        var imageId =
                            await ImageDownloader.downloadImage(widget.img!);
                        if (imageId == null) {
                          return;
                        }
                        Fluttertoast.showToast(msg: "Image Saved to Gallery");
                        total = widget.downloads! + 1;
                        FirebaseFirestore.instance
                            .collection("wallpaper")
                            .doc(widget.docId)
                            .update({"downloads": total}).then((value) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const HomeScreen()));
                        });
                      } on PlatformException catch (error) {
                        print(error);
                      }
                    },
                    c1: Colors.green,
                    c2: Colors.lightGreen,
                  ),
                ),
                FirebaseAuth.instance.currentUser!.uid == widget.userId
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8.0),
                        child: ButtonSquare(
                          text: "Delete",
                          c1: Colors.green,
                          c2: Colors.greenAccent,
                          press: () async {
                            FirebaseFirestore.instance
                                .collection("wallpaper")
                                .doc(widget.docId)
                                .delete()
                                .then((value) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => const HomeScreen()));
                            });
                          },
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8.0),
                  child: ButtonSquare(
                    text: "GO Back",
                    c1: Colors.green,
                    c2: Colors.greenAccent,
                    press: () async {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const HomeScreen()));
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
