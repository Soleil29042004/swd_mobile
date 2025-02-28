import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  //Create an instance for Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  //function to initialize notif
  Future<void> initNotifications() async {
    //request permission from user
    await _firebaseMessaging.requestPermission();
    //fetch FCM token from this device
    final fCMToken = await _firebaseMessaging.getToken();
    //print the token
    print('Token: $fCMToken');
  }
}