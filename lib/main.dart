import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swd_mobile/api/firebase_api.dart';
import 'package:swd_mobile/pages/home.dart';
import 'package:swd_mobile/pages/login.dart';
import 'package:flutter/foundation.dart';
import 'package:swd_mobile/pages/notification.dart';
import 'package:swd_mobile/pages/profile.dart';
import 'package:swd_mobile/pages/inventory.dart';
import 'package:google_fonts/google_fonts.dart';

// Conditional import for web only
// This ensures dart:html is only imported when targeting web platforms
import 'web_utilities.dart' if (dart.library.io) 'mobile_utilities.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For non-web platforms, Firebase can often auto-detect the config
  if (!kIsWeb) {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } else {
    // For web, we need to provide the options
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyDTAw1LwpO9epN9Ad9iiyeH0kmMG6YGTcY",
          authDomain: "swd-pushnotif.firebaseapp.com",
          projectId: "swd-pushnotif",
          storageBucket: "swd-pushnotif.appspot.com",
          messagingSenderId: "999904748547",
          appId: "1:999904748547:web:2b458b4e6c6cc671539a36",
        ),
      );
    }
    registerServiceWorker();
  }

  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'system',
        ),
        home: LoginPage(),
        navigatorKey: navigatorKey,
        routes: {
          'notification':(context) => const NotificationPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/profile': (context) => ProfilePage(),
          '/search': (context) => InvetoryScreen(),
        }
    );
  }
}