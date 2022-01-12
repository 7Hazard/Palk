import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uni_links/uni_links.dart';

import 'firebase_options.dart';
import 'models/profile.dart';

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
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: const Color(0xFFEFEFEF)),
      ),
      home: HomeScreen(),
    );
  }
}

Future<void> initFirebase() async {
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
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    String token = (await messaging.getToken())!;
    print('FCM token: ${token}');
    Profile.current = await Profile.get(token);
  }
}

Future<void> initUniLinks() async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    final initialLink = await getInitialLink();
    if (initialLink == null) return;
    // Parse the link and warn the user, if it is not correct,

    print(initialLink);

    // Attach a listener to the stream
    StreamSubscription _sub;
    _sub = linkStream.listen((String? link) {
      // Parse the link and warn the user, if it is not correct
      print(link);
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // var chatMatch = RegExp(r"palk:\/\/chat\?id=(.*.)&key=(.*)&name=(.*)")
    //     .matchAsPrefix(initialLink);
    // if (chatMatch != null) {
    //   var id = chatMatch.group(1)!;
    //   var key = chatMatch.group(2)!;
    //   var name = String.fromCharCodes(base64Decode(chatMatch.group(3)!));
    //   // Chat.add(id, key, name).then((value) {
    //   //   print("Joined chat '${name}'");
    //   //   controller.stopCamera();
    //   //   controller.dispose();
    //   //   Navigator.pop(context);
    //   // }).catchError((e){
    //   //   controller.resumeCamera();
    //   // });
    // } else {
    //   print("Can't process url '${initialLink}'");
    // }
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
  }
}
