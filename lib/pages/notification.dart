import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:swd_mobile/components.dart'; // Import the components file

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    //get the notification message and display on screen
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;

    // Define the state for drawer sections
    Map<String, bool> drawerSectionState = {};

    return Scaffold(
      appBar: buildAppBar(context), // Use the AppBar from components.dart
      drawer: buildNavigationDrawer(
        context,
        drawerSectionState,
            (Function callback) => callback(), // Dummy setState function
      ),
      body: Column(
        children: [
          Text(message.notification!.title.toString()),
          Text(message.notification!.body.toString()),
          Text(message.data.toString()),
        ],
      ),
    );
  }
}
