// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photosharing/SERVICES/global_variables.dart';
import 'package:photosharing/home_screen/homeScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Animation<double> _animation;
  late AnimationController _animationController;
  final TextEditingController _fullnameController =
      TextEditingController(text: "");
  final TextEditingController _emailController =
      TextEditingController(text: "");
  final TextEditingController _passwordController =
      TextEditingController(text: "");
  final TextEditingController _phoneNumberController =
      TextEditingController(text: "");
  final _signUpFormKey = GlobalKey<FormState>();
  File? imageFile;

  final FocusNode _emailFocsNode = FocusNode();
  final FocusNode _passwordFocsNode = FocusNode();
  final FocusNode _phoneNumberFocsNode = FocusNode();

  bool _isLoading = false;
  bool _obscureText = true;
  String? imageUrl;
  @override
  void dispose() {
    _animationController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _emailFocsNode.dispose();
    _passwordFocsNode.dispose();
    _phoneNumberFocsNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 10,
      ),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((animationStatus) {
        if (animationStatus == AnimationStatus.completed) {
          _animationController.reset();
          _animationController.forward();
        }
      });
    _animationController.forward();
    super.initState();
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
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _submitFormSignUp() async {
    if (imageFile == null) {
      Fluttertoast.showToast(msg: "Please select an image");
      return;
    }
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("userImages")
          .child(DateTime.now().toString() + '.jpg');
      await ref.putFile(imageFile!);
      imageUrl = await ref.getDownloadURL();
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );
      final User? user = _auth.currentUser;
      final _uid = user!.uid;
      FirebaseFirestore.instance.collection("users").doc(_uid).set({
        'id': _uid,
        'userImage': imageUrl,
        'name': _fullnameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
        'createdAt': Timestamp.now(),
      });
      Navigator.canPop(context) ? Navigator.pop(context) : null;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (c) => HomeScreen()));
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: signUpUrlImage,
            placeholder: (context, url) => Image.asset(
              "images/wallpaper.jpg",
              fit: BoxFit.fill,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Form(
                    key: _signUpFormKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showImageDialog();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: size.width * 0.24,
                              height: size.width * 0.24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.cyanAccent,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: imageFile == null
                                    ? const Icon(
                                        Icons.camera_enhance_sharp,
                                        color: Colors.cyan,
                                        size: 30,
                                      )
                                    : Image.file(
                                        imageFile!,
                                        fit: BoxFit.fill,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          child: Column(
                            children: [
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_emailFocsNode),
                                keyboardType: TextInputType.name,
                                controller: _fullnameController,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Please enter a your name !";
                                  } else {
                                    return null;
                                  }
                                },
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Name",
                                  hintStyle: TextStyle(color: Colors.white),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_emailFocsNode),
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                validator: (val) {
                                  if (val!.isEmpty || !val.contains("@")) {
                                    return "Please enter a valid email !";
                                  } else {
                                    return null;
                                  }
                                },
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.white),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                focusNode: _passwordFocsNode,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_passwordFocsNode),
                                keyboardType: TextInputType.visiblePassword,
                                controller: _passwordController,
                                obscureText: !_obscureText,
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 7) {
                                    return "Please enter a valid password";
                                  } else {
                                    return null;
                                  }
                                },
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                    child: Icon(
                                      _obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                                  ),
                                  hintText: "Password",
                                  hintStyle:
                                      const TextStyle(color: Colors.white),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_phoneNumberFocsNode),
                                keyboardType: TextInputType.phone,
                                controller: _phoneNumberController,
                                validator: (val) {
                                  if (val!.isEmpty || val.length < 10) {
                                    return "Please enter a valid phone number !";
                                  } else {
                                    return null;
                                  }
                                },
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Phone Number",
                                  hintStyle: TextStyle(color: Colors.white),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : MaterialButton(
                                      onPressed: _submitFormSignUp,
                                      color: Colors.cyan,
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              "Signup",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 25),
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Already have an account?",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const TextSpan(text: "     "),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () =>
                                              Navigator.canPop(context)
                                                  ? Navigator.pop(context)
                                                  : null,
                                        text: "Login",
                                        style: const TextStyle(
                                          color: Colors.cyan,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
