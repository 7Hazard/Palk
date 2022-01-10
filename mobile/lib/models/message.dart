
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
  static Future<List<Message>> getAll(String chatId) async {
    try {
      String json = await channel.invokeMethod('getMessages', chatId);
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

  static Future<bool> send(String message, String chatid, String key) async {
    final algorithm = AesGcm.with256bits();
    final secretKey =
        await algorithm.newSecretKeyFromBytes(utf8.encode(key));
    final nonce = algorithm.newNonce();

    var data = jsonEncode({
      "content": message,
      "from": await FirebaseMessaging.instance.getToken(),
      "name": "Mille",
      "time": DateTime.now().toUtc().toIso8601String()
    });

    // Encrypt
    final secretBox = await algorithm.encrypt(
      utf8.encode(data),
      secretKey: secretKey,
      nonce: nonce,
    );
    var encryptedData = base64Encode(secretBox.concatenation());

    var url = Uri.parse('https://palk.7hazard.workers.dev/messages');
    var response = await http.post(url,
        body: jsonEncode({"chat": chatid, "data": encryptedData}));
    return response.statusCode == 200;
  }
}

// YOU - current user
final Profile currentUser = Profile(
  id: "",
  name: 'Current User',
  avatar: 'assets/images/greg.jpg',
);
