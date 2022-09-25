import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:photosharing/home_screen/homeScreen.dart';
import 'package:photosharing/login/login_screen.dart';

class USerState extends StatelessWidget {
  const USerState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const LoginScreen();
        } else if (snapshot.hasData) {
          return HomeScreen();
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text("An error has been occurred.Try again later."),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: Text("Something went wrong.."),
          ),
        );
      },
    );
  }
}
