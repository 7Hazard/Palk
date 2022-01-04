import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/models/message_model.dart';
import 'package:flutter_chat_ui/models/user_model.dart';
import 'package:flutter_chat_ui/screens/chat_screen.dart';

class RecentChats extends StatelessWidget {
  static const platform = MethodChannel('solutions.desati.palk/chats');

  Future<Map<String, dynamic>> getChats() async {
    try {
      var json = await platform.invokeMethod('getChats');
      Map<String, dynamic> obj = jsonDecode(json);
      return obj["chats"];
    } on PlatformException catch (e) {
      print("Could not get chats data:\n\t${e}");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: FutureBuilder<Map<String, dynamic>>(
                future: getChats(),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> chats = snapshot.data;
                    var lastmessages = chats.map((key, chat) {
                      var lastmsg = chat["lastMessage"];
                      if (lastmsg == null) {
                        return MapEntry(
                            key,
                            Message(
                              sender: User(
                                id: 0,
                                name: 'New chat',
                                imageUrl: 'assets/images/greg.jpg',
                              ),
                              time: "",
                              text: "No messages yet",
                              unread: false,
                              isLiked: false,
                            ));
                      } else {
                        return MapEntry(
                            key,
                            Message(
                              sender: User(
                                id: 0,
                                name: 'Mille',
                                imageUrl: 'assets/images/greg.jpg',
                              ),
                              time: lastmsg["time"],
                              text: lastmsg["content"],
                              unread: true,
                              isLiked: false,
                            ));
                      }
                    });

                    return ListView.builder(
                      itemCount: lastmessages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Message lastmessage =
                            lastmessages.values.elementAt(index);
                        final String chatid =
                            lastmessages.keys.elementAt(index);
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatid: chatid,
                                user: lastmessage.sender,
                              ),
                            ),
                          ),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      lastmessage.time,
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
                  } else {
                    return ListView();
                  }
                })),
      ),
    );
  }
}
