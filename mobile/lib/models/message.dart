
import 'dart:convert';

import 'package:flutter/services.dart';

import '../util.dart';
import 'profile.dart';

class Message {
  final Profile sender;
  final DateTime time; // Would usually be type DateTime or Firebase Timestamp in production apps
  final String text;
  final bool isLiked;
  final bool unread;

  Message({
    this.sender,
    this.time,
    this.text,
    this.isLiked,
    this.unread,
  });

  static const channel = MethodChannel('solutions.desati.palk/messages');
  static Future<List<Message>> getAll(String chatid) async {
    try {
      var json = await read("chat-${chatid}");
      List<dynamic> jsonlist = jsonDecode(json);
      var messages = jsonlist
          .map((msg) => Message(
                sender: Profile(
                  id: "",
                  name: 'Mille',
                  avatar: 'assets/images/greg.jpg',
                ),
                time: DateTime.parse(msg["time"]),
                text: msg["content"],
                unread: true,
                isLiked: false,
              ))
          .toList();
      messages.sort((a, b) => b.time.compareTo(a.time));
      return messages;
    } on PlatformException catch (e) {
      print("Could not get messages:\n\t${e}");
      return null;
    }
  }
}
