import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  @override
  Widget build(BuildContext context) {
    var username = '';

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Profile Settings'),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 16, top: 25, right: 16),
          child: Column(
            children: [
              Text(
                'Username: Mil3nium',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
              TextField(
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.only(left: 16, top: 25, right: 16),
                    labelText: 'Username',
                    hintText: 'Enter username...'),
              ),
              Padding(padding: EdgeInsets.only(left: 16, top: 50, right: 16)),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Save',
                ),
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.black,
                    textStyle: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ));
  }
}
