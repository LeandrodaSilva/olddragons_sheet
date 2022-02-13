// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDk90Fu0YWuTfuhNCG0Jsfei1VyngZ3Pfc',
    appId: '1:315957121112:web:f22a65cf91b50fcb3f7a2d',
    messagingSenderId: '315957121112',
    projectId: 'olddragons-sheet',
    authDomain: 'olddragons-sheet.firebaseapp.com',
    storageBucket: 'olddragons-sheet.appspot.com',
    measurementId: 'G-VP13FD7YWY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbmss6UxQF53-GqnTvypBk1n8xXTwi83Q',
    appId: '1:315957121112:android:21e88ad05e2a95a93f7a2d',
    messagingSenderId: '315957121112',
    projectId: 'olddragons-sheet',
    storageBucket: 'olddragons-sheet.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATk5xvUnTSQuIBi4Psh3ZXs7zYvsRvrIo',
    appId: '1:315957121112:ios:df077f75a102c21c3f7a2d',
    messagingSenderId: '315957121112',
    projectId: 'olddragons-sheet',
    storageBucket: 'olddragons-sheet.appspot.com',
    androidClientId:
        '315957121112-f2pmo49rrf5q99hbfuqp49rvren0454a.apps.googleusercontent.com',
    iosClientId:
        '315957121112-88lb7d650shjed2m4vaoo4ks4in8r6qn.apps.googleusercontent.com',
    iosBundleId: 'com.lesys.ods',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyATk5xvUnTSQuIBi4Psh3ZXs7zYvsRvrIo',
    appId: '1:315957121112:ios:df077f75a102c21c3f7a2d',
    messagingSenderId: '315957121112',
    projectId: 'olddragons-sheet',
    storageBucket: 'olddragons-sheet.appspot.com',
    androidClientId:
        '315957121112-f2pmo49rrf5q99hbfuqp49rvren0454a.apps.googleusercontent.com',
    iosClientId:
        '315957121112-88lb7d650shjed2m4vaoo4ks4in8r6qn.apps.googleusercontent.com',
    iosBundleId: 'com.lesys.ods',
  );
}
