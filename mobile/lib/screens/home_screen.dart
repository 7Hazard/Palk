import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/models/chat.dart';
import 'package:flutter_chat_ui/models/message.dart';
import 'package:flutter_chat_ui/models/profile.dart';
import 'package:flutter_chat_ui/screens/new_chat_screen.dart';
import 'package:flutter_chat_ui/screens/profile_settings_screen.dart';
import 'package:flutter_chat_ui/screens/scan_code_screen.dart';
import 'package:intl/intl.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
              );
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
              icon: Icon(Icons.access_alarm),
              iconSize: 30.0,
              color: Colors.black,
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
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
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewChatScreen(),
                  ),
                ).then((value) {
                  setState(() {
                    print('updated homescreen');
                  });
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
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanCodeScreen(),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              ),
            )
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
                builder:
                    (BuildContext context, AsyncSnapshot<Map<String, Chat>> snapshot) {
                  if (snapshot.hasData) {
                    var chatsMap = snapshot.data;
                    if (chatsMap.isEmpty) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text('No messages'),
                            )
                          ]);
                    } else {
                      var chats = chatsMap.values.toList();
                      // [a, b, c, null, null]
                      chats.sort((a, b) {
                        if (a.lastUpdate == null && b.lastUpdate == null) {
                          return 0;
                        } else if (a.lastUpdate == null) {
                          return 1;
                        } else if (b.lastUpdate == null) {
                          return -1;
                        } else {
                          return b.lastUpdate.compareTo(a.lastUpdate);
                        }
                      });
                      return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (BuildContext context, int index) {
                          var chat = chats[index];

                          FirebaseMessaging.instance
                              .subscribeToTopic(chat.id); // TEMP

                          var lastmessage = chat.lastMessage != null
                              ? chat.lastMessage
                              : Message(
                                  sender: Profile(
                                    id: "",
                                    name: 'Mille',
                                    avatar: 'assets/images/greg.jpg',
                                  ),
                                  text: "No messages yet",
                                  time: DateTime.now(),
                                  isLiked: false,
                                  unread: false);
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(chat: chat),
                              ),
                            ).then((value) {
                              setState(() {});
                            }),
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: 5.0, bottom: 5.0, right: 20.0),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: lastmessage.unread
                                    ? Color(0xFFFFEFEE)
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                ),
                              ),
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
                                            lastmessage.sender.name,
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
                                            child: Text(
                                              lastmessage.text,
                                              style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
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
                                                lastmessage.time.toString())),
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      lastmessage.unread
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
