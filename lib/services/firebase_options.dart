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
    apiKey: 'AIzaSyAoghTyv46gHt3EXTt9oZqVnYSZOi09zQg',
    appId: '1:465795601024:web:graduation_app',
    messagingSenderId: '465795601024',
    projectId: 'emergicam12',
    authDomain: 'emergicam12.firebaseapp.com',
    storageBucket: 'emergicam12.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAoghTyv46gHt3EXTt9oZqVnYSZOi09zQg',
    appId: '1:465795601024:android:1672fa82b9f05988270c65',
    messagingSenderId: '465795601024',
    projectId: 'emergicam12',
    storageBucket: 'emergicam12.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAoghTyv46gHt3EXTt9oZqVnYSZOi09zQg',
    appId: '1:465795601024:ios:36401a117b9958da3e8e21',
    messagingSenderId: '465795601024',
    projectId: 'emergicam12',
    iosBundleId: 'com.emergicam.app',
    storageBucket: 'emergicam12.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAoghTyv46gHt3EXTt9oZqVnYSZOi09zQg',
    appId: '1:465795601024:ios:36401a117b9958da3e8e21',
    messagingSenderId: '465795601024',
    projectId: 'emergicam12',
    iosBundleId: 'com.emergicam.app',
    storageBucket: 'emergicam12.firebasestorage.app',
  );
}
