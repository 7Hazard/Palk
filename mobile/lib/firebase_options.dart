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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAW7ST9soKy8cUDjcGmZO9pPOGHry-QabI',
    appId: '1:745496417958:web:216c4871d40476ede58667',
    messagingSenderId: '745496417958',
    projectId: 'palk-bfab3',
    authDomain: 'palk-bfab3.firebaseapp.com',
    storageBucket: 'palk-bfab3.appspot.com',
    measurementId: 'G-ZJVJSLFGRK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDB3t1Vb8kLrgY47CbKCjcOxuZCG7GisME',
    appId: '1:745496417958:android:060b4816ae7d00d2e58667',
    messagingSenderId: '745496417958',
    projectId: 'palk-bfab3',
    storageBucket: 'palk-bfab3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUxyr8dCFZJn_XsE-Xj-dbtVHLAzDAY68',
    appId: '1:745496417958:ios:b6c62e1e7cd38d52e58667',
    messagingSenderId: '745496417958',
    projectId: 'palk-bfab3',
    storageBucket: 'palk-bfab3.appspot.com',
    iosClientId: '745496417958-reuiucjvs0vnvnmoekadhue44f551kue.apps.googleusercontent.com',
    iosBundleId: 'solutions.desati.palk',
  );
}