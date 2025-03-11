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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // Replace these values with the ones from your Firebase project configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4ENaWcJ42kU4V4g_ysaldkRhWikLBXGw',
    appId: '1:447906128798:android:b55c38c3ad3af2955e2c8f',
    messagingSenderId: '447906128798',
    projectId: 'bookly-22006',
    storageBucket: 'bookly-22006.appspot.com',
  );

  // Replace these values with the ones from your Firebase project configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'bookly-22006',
    storageBucket: 'bookly-22006.firebasestorage.com',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'com.yourcompany.bookly',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR-WEB-API-KEY',
    appId: 'YOUR-WEB-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'bookly-22006',
    storageBucket: 'bookly-22006.appspot.com',
    authDomain: 'bookly-22006.firebaseapp.com',
  );
}