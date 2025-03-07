// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyBatXCiYzFjuW57PZC4eJ98VJ-1NtEqZ7Q',
    appId: '1:753899941635:web:cede5427852a636b374336',
    messagingSenderId: '753899941635',
    projectId: 'school-timetable-notif',
    authDomain: 'school-timetable-notif.firebaseapp.com',
    storageBucket: 'school-timetable-notif.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgSjctjMQeb90jaxJXa46AQ2RhY0sE-34',
    appId: '1:753899941635:android:4ce8d19a9eba9b7c374336',
    messagingSenderId: '753899941635',
    projectId: 'school-timetable-notif',
    storageBucket: 'school-timetable-notif.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDXCbwYkI1OMSXimTQi_DsO1hSGAQa8EwQ',
    appId: '1:753899941635:ios:b48e3acb40aad173374336',
    messagingSenderId: '753899941635',
    projectId: 'school-timetable-notif',
    storageBucket: 'school-timetable-notif.appspot.com',
    iosBundleId: 'com.example.testTestTest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDXCbwYkI1OMSXimTQi_DsO1hSGAQa8EwQ',
    appId: '1:753899941635:ios:07253efdc49caef0374336',
    messagingSenderId: '753899941635',
    projectId: 'school-timetable-notif',
    storageBucket: 'school-timetable-notif.appspot.com',
    iosBundleId: 'com.example.testTestTest.RunnerTests',
  );
}
