import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palk/models/chat.dart';
import 'package:palk/models/chat_entry.dart';
import 'package:palk/models/profile.dart';
import 'package:palk/screens/new_chat_screen.dart';
import 'package:palk/screens/profile_settings_screen.dart';
import 'package:palk/screens/scan_code_screen.dart';
import 'package:palk/util.dart';
import 'package:intl/intl.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController usernameController = new TextEditingController();

  Future onChatActivity(Chat chat, ChatEntry entry) async {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Chat.subscribeOnActivity(onChatActivity);
  }

  @override
  void dispose() {
    Chat.unsubscribeOnActivity(onChatActivity);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Profile.current == null || Profile.current!.name == null) {
      return AlertDialog(
        title: Text('What is your name?'),
        content: TextField(
          decoration: InputDecoration(hintText: 'John Doe'),
          onSubmitted: (value) async {
            Profile.current = Profile(
              (await FirebaseMessaging.instance.getToken())!,
              name: value,
            );
            Profile.current!.save();
            setState(() {});
          },
        ),
      );
    }

    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: Icon(Icons.account_circle_outlined),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileSettings()),
              ).then((value) {
                setState(() {});
              });
            },
          ),
          title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Center(
                child: Text(
              'Palk ',
              style: TextStyle(
                fontFamily: 'OpenSansBold',
                fontSize: 26.0,
              ),
            )),
            Image.asset(
              'assets/images/palk_icon.png',
              height: 25,
              width: 25,
            )
          ]),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help_outline),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    buildRecentChats(),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "newChat",
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewChatScreen(),
                  ),
                ).then((value) {
                  setState(() {});
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),

            SizedBox(width: 10), // Padding

            FloatingActionButton(
              heroTag: "scanCode",
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanCodeScreen(),
                  ),
                ).then((value) {
                  setState(() {});
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              ),
            ),

            SizedBox(width: 10), // Padding

            FloatingActionButton(
              heroTag: "fromClipboard",
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () async {
                try {
                  var clipboard = await Clipboard.getData(Clipboard.kTextPlain);
                  var url = clipboard!.text!;
                  var match =
                      RegExp(r"palk:\/\/chat\?id=(.*.)&key=(.*)&name=(.*)")
                          .matchAsPrefix(url)!;
                  var id = match.group(1)!;
                  var key = match.group(2)!;
                  var name =
                      String.fromCharCodes(base64Decode(match.group(3)!));
                  var chat = await Chat.get(id);
                  if (chat != null) {
                    Util.snackbar(context, 'Already member of ${name}');
                  } else {
                    chat = await Chat.add(id, key, name);
                    Util.snackbar(context, 'Joined ${name}');
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chat!),
                    ),
                  ).then((value) {
                    setState(() {});
                  });
                } catch (e) {
                  print("Invalid chat code in clipboard");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Invalid chat code in clipboard'),
                  ));
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(
                Icons.pin,
                color: Colors.white,
              ),
            ),
          ],
        ));
  }

  Widget buildRecentChats() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: FutureBuilder(
                future: Chat.all,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, Chat>?> snapshot) {
                  if (snapshot.hasData) {
                    var chatsMap = snapshot.data!;
                    if (chatsMap.isEmpty) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text('No chats'),
                            )
                          ]);
                    } else {
                      var chats = chatsMap.values.toList();
                      chats.sort((a, b) => b.updated.compareTo(a.updated));
                      return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (BuildContext context, int index) {
                          var chat = chats[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(chat),
                              ),
                            ).then((value) {
                              setState(() {});
                            }),
                            child: Container(
                              // margin: EdgeInsets.only(
                              //   top: 5.0,
                              //   bottom: 5.0,
                              // ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20.0),
                              decoration: BoxDecoration(
                                  color: chat.updated.isAfter(chat.read)
                                      ? Color(0xFFFFEFEE)
                                      : Colors.white,
                                  // borderRadius: BorderRadius.only(
                                  //   topRight: Radius.circular(20.0),
                                  //   bottomRight: Radius.circular(20.0),
                                  // ),
                                  border: Border.all(color: Colors.black45)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      SizedBox(width: 10.0),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            chat.name,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5.0),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                            child: chat.latestEntry != null
                                                ? Text(
                                                    chat.latestEntry!
                                                        .description,
                                                    style: TextStyle(
                                                      color: Colors.blueGrey,
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        DateFormat("yyyy-MM-dd").format(
                                            DateTime.parse(
                                                chat.updated.toString())),
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      chat.updated.isAfter(chat.read)
                                          ? Container(
                                              width: 40.0,
                                              height: 20.0,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'NEW',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : Text(''),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  } else {
                    return ListView();
                  }
                })),
      ),
    );
  }
}
