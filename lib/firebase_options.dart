import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Temporary Firebase options file.
///
/// IMPORTANT: Replace this file by running:
///   flutterfire configure
///
/// The real file will contain your Firebase project apiKey, appId,
/// messagingSenderId and projectId. This placeholder only keeps the project
/// structure complete until you connect your own Firebase project.
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
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJIAJYfql1o4JLqo_4ZkTdK2Gxm85jKJ8',
    appId: '1:407096058536:android:7cb240366d67aff366d89d',
    messagingSenderId: '407096058536',
    projectId: 'mylifeplanner-8dea6',
    storageBucket: 'mylifeplanner-8dea6.firebasestorage.app',
  );
  static const FirebaseOptions ios = android;
  static const FirebaseOptions macos = android;
  static const FirebaseOptions web = android;
  static const FirebaseOptions windows = android;
  static const FirebaseOptions linux = android;
}
