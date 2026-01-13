// Firebase configuration for Tribe app
// Supports Web, Android, iOS, macOS, Windows

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return web; // Windows uses web config
      case TargetPlatform.linux:
        return web; // Linux uses web config
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web configuration (also used for Windows/Linux desktop)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAO9Rk9fagU39RK7kdj-QTn_t_D_ZqA2kU',
    appId: '1:411728040248:web:2510271d4ceb1858a471cd',
    messagingSenderId: '411728040248',
    projectId: 'tribe-9c238',
    authDomain: 'tribe-9c238.firebaseapp.com',
    storageBucket: 'tribe-9c238.firebasestorage.app',
    measurementId: 'G-G10NJW1Z3Y',
  );

  // Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAY4Mimj0UpTmsRu3t_U6x0jt03ti4NTU',
    appId: '1:411728040248:android:7b6c61406c4e921ba471cd',
    messagingSenderId: '411728040248',
    projectId: 'tribe-9c238',
    storageBucket: 'tribe-9c238.firebasestorage.app',
  );

  // iOS placeholder
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAO9Rk9fagU39RK7kdj-QTn_t_D_ZqA2kU',
    appId: '1:411728040248:web:2510271d4ceb1858a471cd',
    messagingSenderId: '411728040248',
    projectId: 'tribe-9c238',
    storageBucket: 'tribe-9c238.firebasestorage.app',
    iosBundleId: 'com.ntua.tribe',
  );

  // macOS placeholder
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAO9Rk9fagU39RK7kdj-QTn_t_D_ZqA2kU',
    appId: '1:411728040248:web:2510271d4ceb1858a471cd',
    messagingSenderId: '411728040248',
    projectId: 'tribe-9c238',
    storageBucket: 'tribe-9c238.firebasestorage.app',
    iosBundleId: 'com.ntua.tribe',
  );
}
