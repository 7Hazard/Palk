import 'package:flutter/material.dart';
import 'package:palk/models/chat.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../util.dart';

class ChatSettings extends StatefulWidget {
  final Chat chat;

  ChatSettings(this.chat);

  @override
  _ChatSettingsState createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    var qr_image = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: new Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 0.0),
              child: TextButton(
                onPressed: () {
                  widget.chat.copyUrlToClipboard();
                  Util.snackbar(context, "Copied chat code to clipboard");
                },
                child: Container(
                  color: Colors.white,
                  // padding: EdgeInsets.all(20),
                  child: QrImage(
                    data: widget.chat.url,
                    version: QrVersions.auto,
                    size: 200.0, // Determines QR-code size
                  ),
                ),
              ),
            ),
          ),
        ]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: <Widget>[
          qr_image,
          Expanded(
              child: ListView(children: <Widget>[
            SettingsListItem(
              icon: Icons.notifications,
              text: 'Notifications',
            ),
            SettingsListItem(
              icon: Icons.volume_mute,
              text: 'Sound',
            ),
            TextButton(
              onPressed: () {
                widget.chat.remove();
                Util.snackbar(context, 'Left ${widget.chat.name}');
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Leave',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ]))
        ],
      ),
    );
  }
}

class SettingsListItem extends StatelessWidget {
  final IconData? icon;
  final text;

  const SettingsListItem({Key? key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10)
          .copyWith(bottom: 0),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey,
      ),
      child: Row(
        children: [
          Icon(this.icon, size: 20),
          SizedBox(width: 20),
          Text(this.text),
          Spacer(),
          Switch(value: true, onChanged: (bool value) {})
        ],
      ),
    );
  }
}
