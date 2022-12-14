// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCWyopFtbMlhr7SH1Qw-uJukf4l5ZsbKFI',
    appId: '1:18038406368:web:3d8e0afb14e4f42683e485',
    messagingSenderId: '18038406368',
    projectId: 'photosharing-431ec',
    authDomain: 'photosharing-431ec.firebaseapp.com',
    storageBucket: 'photosharing-431ec.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDtZtUvlLvTTuhiMX51DQJwM7MPLr2Hj68',
    appId: '1:18038406368:android:90fa7e4a1771902e83e485',
    messagingSenderId: '18038406368',
    projectId: 'photosharing-431ec',
    storageBucket: 'photosharing-431ec.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAX0AL_Tdu9pDxGFkrSUUll3TAN70eP_Ro',
    appId: '1:18038406368:ios:4b3de82ed1dbf7a983e485',
    messagingSenderId: '18038406368',
    projectId: 'photosharing-431ec',
    storageBucket: 'photosharing-431ec.appspot.com',
    iosClientId: '18038406368-q715u884tqh7lahduq10a63rq4vn4925.apps.googleusercontent.com',
    iosBundleId: 'com.example.photosharing',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAX0AL_Tdu9pDxGFkrSUUll3TAN70eP_Ro',
    appId: '1:18038406368:ios:4b3de82ed1dbf7a983e485',
    messagingSenderId: '18038406368',
    projectId: 'photosharing-431ec',
    storageBucket: 'photosharing-431ec.appspot.com',
    iosClientId: '18038406368-q715u884tqh7lahduq10a63rq4vn4925.apps.googleusercontent.com',
    iosBundleId: 'com.example.photosharing',
  );
}
