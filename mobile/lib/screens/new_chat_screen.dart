import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/models/chat.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

import '../util.dart';

class NewChatScreen extends StatefulWidget {
  NewChatScreen();

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  @override
  Widget build(BuildContext context) {
    var id = Uuid().v1();
    var key = Util.randomString(32);
    var name = "New chat";

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
            child: FutureBuilder(
                future: Chat.add(id, key, name),
                builder: (context, AsyncSnapshot<Chat> snapshot) {
                  if (snapshot.hasData) {
                    var chat = snapshot.data!;
                    return Padding(
                      child: TextButton(
                        onPressed: () {
                          chat.copyUrlToClipboard();
                        },
                        child: QrImage(
                          data: chat.url,
                          version: QrVersions.auto,
                          size: 200.0, // Determines QR-code size
                        ),
                      ),
                      padding: EdgeInsets.only(bottom: 30),
                    );
                  } else
                    return Text("");
                }),
          ),
          Padding(
              child: Text('Scan the QR-code to join the chat'),
              padding: EdgeInsets.only(bottom: 150)),
        ],
      ),
    );
  }
}
