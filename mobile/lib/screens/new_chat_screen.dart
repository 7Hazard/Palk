import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/models/message_model.dart';
import 'package:flutter_chat_ui/models/user_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class NewChatScreen extends StatefulWidget {
  NewChatScreen();

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  @override
  Widget build(BuildContext context) {
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
              data: Uuid().v1(),
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
