// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyBE2VpY7Y9N1zVyb8J3XuPj4xNtdMeqtNU',
    appId: '1:366519586548:web:ef6e91c443e81df65d18a1',
    messagingSenderId: '366519586548',
    projectId: 'zartek-test-13ea2',
    authDomain: 'zartek-test-13ea2.firebaseapp.com',
    storageBucket: 'zartek-test-13ea2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmFjGpM92vgIBp71O79r4zfj0q38u8UfQ',
    appId: '1:366519586548:android:518e405d5684257f5d18a1',
    messagingSenderId: '366519586548',
    projectId: 'zartek-test-13ea2',
    storageBucket: 'zartek-test-13ea2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDzNdxHDj1uaWkG79syp0Nqzz3EqgL-njY',
    appId: '1:366519586548:ios:99866e6154fcba255d18a1',
    messagingSenderId: '366519586548',
    projectId: 'zartek-test-13ea2',
    storageBucket: 'zartek-test-13ea2.firebasestorage.app',
    iosBundleId: 'com.example.zartekTask',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDzNdxHDj1uaWkG79syp0Nqzz3EqgL-njY',
    appId: '1:366519586548:ios:99866e6154fcba255d18a1',
    messagingSenderId: '366519586548',
    projectId: 'zartek-test-13ea2',
    storageBucket: 'zartek-test-13ea2.firebasestorage.app',
    iosBundleId: 'com.example.zartekTask',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBE2VpY7Y9N1zVyb8J3XuPj4xNtdMeqtNU',
    appId: '1:366519586548:web:1a44945295d94b0d5d18a1',
    messagingSenderId: '366519586548',
    projectId: 'zartek-test-13ea2',
    authDomain: 'zartek-test-13ea2.firebaseapp.com',
    storageBucket: 'zartek-test-13ea2.firebasestorage.app',
  );
}