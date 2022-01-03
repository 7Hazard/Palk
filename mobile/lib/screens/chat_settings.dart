import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatSettings extends StatefulWidget {
  @override
  _ChatSettingsState createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
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
                  const EdgeInsets.symmetric(vertical: 50.0, horizontal: 0.0),
              child: CircleAvatar(
                radius: 82,
                backgroundColor: Colors.grey,
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/Fake_QR-Code.png'),
                  radius: 80,
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
                child: Text('Leave chat'),
                onPressed: () {
                  print('Pressed');
                })
          ]))
        ],
      ),
    );
  }
}

class SettingsListItem extends StatelessWidget {
  final IconData icon;
  final text;

  const SettingsListItem({Key key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 5).copyWith(bottom: 5),
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
