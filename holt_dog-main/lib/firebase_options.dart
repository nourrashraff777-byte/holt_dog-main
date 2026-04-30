// File generated based on google-services.json
// Project: holt-dog-169fc

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_7nGvB4_hmkwhoaZpoG_KhL52UxFs8uo',
    appId: '1:803746088220:android:8e5e4223dbf32e620926d9',
    messagingSenderId: '803746088220',
    projectId: 'holt-dog-169fc',
    databaseURL: 'https://holt-dog-169fc-default-rtdb.firebaseio.com',
    storageBucket: 'holt-dog-169fc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_7nGvB4_hmkwhoaZpoG_KhL52UxFs8uo',
    appId: '1:803746088220:ios:8e5e4223dbf32e620926d9',
    messagingSenderId: '803746088220',
    projectId: 'holt-dog-169fc',
    databaseURL: 'https://holt-dog-169fc-default-rtdb.firebaseio.com',
    storageBucket: 'holt-dog-169fc.firebasestorage.app',
    iosClientId:
        '803746088220-tt5ubc4dm196k1150cdfv6bte4v3k04b.apps.googleusercontent.com',
    iosBundleId: 'com.holtdog.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_7nGvB4_hmkwhoaZpoG_KhL52UxFs8uo',
    appId: '1:803746088220:web:8e5e4223dbf32e620926d9',
    messagingSenderId: '803746088220',
    projectId: 'holt-dog-169fc',
    databaseURL: 'https://holt-dog-169fc-default-rtdb.firebaseio.com',
    storageBucket: 'holt-dog-169fc.firebasestorage.app',
    authDomain: 'holt-dog-169fc.firebaseapp.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_7nGvB4_hmkwhoaZpoG_KhL52UxFs8uo',
    appId: '1:803746088220:ios:8e5e4223dbf32e620926d9',
    messagingSenderId: '803746088220',
    projectId: 'holt-dog-169fc',
    databaseURL: 'https://holt-dog-169fc-default-rtdb.firebaseio.com',
    storageBucket: 'holt-dog-169fc.firebasestorage.app',
    iosClientId:
        '803746088220-tt5ubc4dm196k1150cdfv6bte4v3k04b.apps.googleusercontent.com',
    iosBundleId: 'com.holtdog.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA_7nGvB4_hmkwhoaZpoG_KhL52UxFs8uo',
    appId: '1:803746088220:web:8e5e4223dbf32e620926d9',
    messagingSenderId: '803746088220',
    projectId: 'holt-dog-169fc',
    databaseURL: 'https://holt-dog-169fc-default-rtdb.firebaseio.com',
    storageBucket: 'holt-dog-169fc.firebasestorage.app',
    authDomain: 'holt-dog-169fc.firebaseapp.com',
  );
}
