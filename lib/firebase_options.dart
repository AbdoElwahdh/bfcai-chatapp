import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpTq-clvLdJpmBA-IhrrX0UcxMwVSjREE',
    appId: '1:826560616846:android:71b2ec5ba8c64b21d7acdf',
    messagingSenderId: '826560616846',
    projectId: 'chat-app-afdb7',
    storageBucket: 'chat-app-afdb7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBwHsx1YzqpXBTQP_dud4FJLSVWDN4u6Js',
    appId: '1:826560616846:ios:8e883a99542f80bad7acdf',
    messagingSenderId: '826560616846',
    projectId: 'chat-app-afdb7',
    storageBucket: 'chat-app-afdb7.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );
}
