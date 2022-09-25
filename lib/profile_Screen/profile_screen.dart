import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photosharing/home_screen/homeScreen.dart';
import 'package:photosharing/login/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name = "";
  String? email = "";
  String? image = "";
  String? phoneNo = "";
  File? imgxFile;
  String? userNameInput = "";
  String? userImageUrl;

  Future _getDataDromDatabase() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!['name'];
          email = snapshot.data()!['email'];
          image = snapshot.data()!['userImage'];
          phoneNo = snapshot.data()!['phoneNumber'];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getDataDromDatabase();
  }

  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (croppedImage != null) {
      setState(() {
        imgxFile = File(croppedImage.path);
        _updateImagfeInFirestore();
      });
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Please choose an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  _getFromCamera();
                },
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.camera,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      "Camera",
                      style: TextStyle(
                        color: Colors.purpleAccent,
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _getFromGallery();
                },
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.image,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      "Gallery",
                      style: TextStyle(
                        color: Colors.purpleAccent,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future _updateUserName() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': userNameInput,
    });
  }

  _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Update your name here:- "),
            content: TextField(
              onChanged: (val) {
                setState(() {
                  userNameInput = val;
                });
              },
              decoration: const InputDecoration(
                hintText: "Type here",
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateUserName();
                  updateNameOnUserExistingPosts();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const HomeScreen())));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _updateImagfeInFirestore() async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    fStorage.Reference reference = fStorage.FirebaseStorage.instance
        .ref()
        .child("userImages")
        .child(fileName);
    fStorage.UploadTask uploadTask = reference.putFile(File(imgxFile!.path));
    fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((url) async {
      userImageUrl = url;
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "userImage": userImageUrl,
    }).whenComplete(() {
      updateProfileImageOnUserExistingPosts();
    });
  }

  updateProfileImageOnUserExistingPosts() async {
    await FirebaseFirestore.instance
        .collection("wallpaper")
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      for (int index = 0; index < snapshot.docs.length; index++) {
        String userProfileImageInPost = snapshot.docs[index]['userImage'];
        if (userProfileImageInPost != userImageUrl) {
          FirebaseFirestore.instance
              .collection("wallpaper")
              .doc(snapshot.docs[index].id)
              .update({
            'userImage': userImageUrl,
          });
        }
      }
    });
  }

  updateNameOnUserExistingPosts() async {
    await FirebaseFirestore.instance
        .collection("wallpaper")
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      for (int index = 0; index < snapshot.docs.length; index++) {
        String userProfileNameInPost = snapshot.docs[index]['name'];
        if (userProfileNameInPost != userNameInput) {
          FirebaseFirestore.instance
              .collection("wallpaper")
              .doc(snapshot.docs[index].id)
              .update({
            'name': userNameInput,
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        centerTitle: true,
        backgroundColor: Colors.pink.shade400,
        title: const Center(
          child: Text(
            'Profile Screen',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.lightGreen,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber, Colors.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.2, 0.9],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _showImageDialog();
              },
              child: CircleAvatar(
                backgroundColor: Colors.amberAccent,
                minRadius: 40,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: imgxFile == null
                      ? NetworkImage(image!)
                      : Image.file(imgxFile!).image,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Name: ${name!}",
                  style: GoogleFonts.aldrich(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _displayTextInputDialog(context);
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Email: ${email!}",
              style: GoogleFonts.aldrich(
                fontSize: 25,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Phone No: ${phoneNo!}",
              style: GoogleFonts.aldrich(
                fontSize: 25,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
