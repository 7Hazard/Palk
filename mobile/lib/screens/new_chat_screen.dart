import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/models/chat.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class NewChatScreen extends StatefulWidget {
  NewChatScreen();

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

String randomString(int length){
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random r = Random();
    return String.fromCharCodes(Iterable.generate(
    length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
}

class _NewChatScreenState extends State<NewChatScreen> {
  @override
  Widget build(BuildContext context) {
    var id = Uuid().v1();
    var key = randomString(32);
    print(key);
    print(key.length);
    var name = "New chat";
    Chat.add(id, key, name);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "New Chat",
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: QrImage(
              data: "palk://chat?id=${id}&key=${key}&name=${name}",
              version: QrVersions.auto,
              size: 200.0, // Determines QR-code size
            ),
          ),
          Padding(padding: EdgeInsets.all(50)),
          Text('Scan QR-code with camera to create a new chat.')
        ],
      ),
    );
  }
}
