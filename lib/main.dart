import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photosharing/firebase_options.dart';
import 'package:photosharing/userState.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text(
                  "Welcome to PINTEREST",
                  style: GoogleFonts.adamina(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text("An error occured, Please wait.."),
              ),
            ),
          );
        }
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Pinterest",
          home: USerState(),
        );
      },
    );
  }
}
// 5:48 / 35:48 com