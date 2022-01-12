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
  TextEditingController groupNameController = new TextEditingController();

  var id = Uuid().v1();
  var key = Util.randomString(32);
  String? name;

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
              child: name != null
                  ? FutureBuilder(
                      future: Chat.add(id, key, name!),
                      builder: (context, AsyncSnapshot<Chat> snapshot) {
                        if (snapshot.hasData) {
                          var chat = snapshot.data!;
                          return Column(children: [
                            Padding(
                              child: TextButton(
                                onPressed: () {
                                  chat.copyUrlToClipboard();
                                  Util.snackbar(
                                      context, "Copied chat code to clipboard");
                                },
                                child: QrImage(
                                  data: chat.url,
                                  version: QrVersions.auto,
                                  size: 200.0, // Determines QR-code size
                                ),
                              ),
                              padding: EdgeInsets.only(bottom: 30),
                            ),
                            Padding(
                                child:
                                    Text('Scan the QR-code to join the chat'),
                                padding: EdgeInsets.only(bottom: 150)),
                          ]);
                        } else
                          return Text("");
                      })
                  : Center(
                      child: TextField(
                        keyboardType: TextInputType.text,
                        onSubmitted: (value) {
                          print(value);
                          setState(() {
                            name = value;
                          });
                        },
                        controller: groupNameController,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 16, top: 25, right: 16),
                            labelText: 'Enter new Groupname here...',
                            hintText: ' '),
                      ),
                    )),
        ],
      ),
    );
  }
}
