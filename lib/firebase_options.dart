import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDXR04oWuoQrmVo4FDFYZfJvSVyZ7yaqN8',
    appId: '1:792393601916:android:1f73ec391286e0e5518af9',
    messagingSenderId: '792393601916',
    projectId: 'findthem-90a3d',
    storageBucket: 'findthem-90a3d.firebasestorage.app',
  );
}
