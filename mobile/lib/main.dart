import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initFirebase();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF000000),
        accentColor: const Color(0xFFEFEFEF),
      ),
      home: HomeScreen(),
    );
  }
}

void initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String token = await messaging.getToken();
    print('FCM token: ${token}');

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // {
  //   print("Printing background logs...");
  //   final LocalStorage storage = new LocalStorage('logs');
  //   await storage.ready;
  //   var lines = storage.getItem("background");
  //   if(lines == null) {
  //     lines = [];
  //     storage.setItem("background", lines);
  //   }

  //   lines.add("Init");
  //   storage.setItem("background", lines);

  //   print("Count: ${lines.length}");
  //   for (var line in lines) {
  //     print(line);
  //   }
  // }
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   // await Firebase.initializeApp();

//   final LocalStorage storage = new LocalStorage('logs');
//   await storage.ready;
//   var lines = storage.getItem("background");
//   lines.add("background message");
//   storage.setItem("background", lines);
  
//   if(message.data != null) {
//     lines.add("Handled message: ${message.data}");
//     storage.setItem("background", lines);
//   }

//   print("Handling a background message: ${message.messageId}");
// }
