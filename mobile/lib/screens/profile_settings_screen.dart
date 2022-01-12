import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/models/profile.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  TextEditingController usernameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          spreadRadius: 3,
                          blurRadius: 20,
                        )
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  height: 70,
                  width: 200,
                  child: ListTile(
                      title: Text('Name:',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                      subtitle: Text(Profile.current!.nameOrDefault()!,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)))),
              Padding(
                  padding: EdgeInsets.symmetric(
                vertical: 15.0,
              )),
              TextField(
                keyboardType: TextInputType.text,
                controller: usernameController,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.only(left: 16, top: 25, right: 16),
                    labelText: 'Enter new username here...',
                    hintText: ' '),
              ),
              Padding(padding: EdgeInsets.only(left: 16, top: 50, right: 16)),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (!usernameController.text.isEmpty) {
                      Profile.current!.name = usernameController.text;
                    }
                  });
                },
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
