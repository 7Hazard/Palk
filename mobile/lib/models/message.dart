import 'dart:convert';

import 'package:flutter/services.dart';

import '../util.dart';
import 'profile.dart';

class Message {
  final Profile sender;
  final DateTime time;
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

  static Future<List<Message>> getAll(String chatid) async {
    try {
      var json = await read("chat-${chatid}");
      List<dynamic> jsonlist = jsonDecode(json);
      List<Message> messages = [];
      jsonlist.forEach((msg) async {
        messages.add(Message(
          sender: await Profile.get(msg["from"], createIfNotExists: true),
          time: DateTime.parse(msg["time"]),
          text: msg["content"],
          unread: true,
          isLiked: false,
        ));
      });
      return messages;
    } on PlatformException catch (e) {
      print("Could not get messages:\n\t${e}");
      return null;
    }
  }
}
