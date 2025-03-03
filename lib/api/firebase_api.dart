import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:swd_mobile/main.dart';

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
    //initialize further settings for push notif
    initPushNotifications();
  }
  //function to handle receive message
  void handleMessage(RemoteMessage? message) {
    //if message in null do nothing
    if (message == null) return;

    //navigate to the when message is received and user taps notification
    navigatorKey.currentState?.pushNamed(
      'notification',
      arguments: message,
    );
  }

  //function to initialize foreground and background settings
  Future initPushNotifications() async{
    //handle notification if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    //attach event listeners for when a notification open the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}