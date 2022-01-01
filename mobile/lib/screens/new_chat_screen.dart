import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/models/message_model.dart';
import 'package:flutter_chat_ui/models/user_model.dart';

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
      body: Center(
        child: Text("QR Code Here"),
      ),
    );
  }
}
