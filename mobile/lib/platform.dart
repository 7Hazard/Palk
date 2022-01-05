import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/chat.dart';
import 'models/message_model.dart';
import 'models/user_model.dart';

const chats = MethodChannel('solutions.desati.palk/chats');

Future<List<Chat>> getChats() async {
  try {
    var json = await chats.invokeMethod('get');
    Map<String, dynamic> obj = jsonDecode(json)["chats"];
    return obj.values
        .map((value) => Chat(
            id: value["id"],
            key: value["key"],
            lastMessage: value["lastMessage"] != null
                ? Message(
                    text: value["lastMessage"]["content"],
                    time: DateTime.parse(value["lastMessage"]["time"]),
                    sender: User(
                      id: 0,
                      name: 'Mille',
                      imageUrl: 'assets/images/greg.jpg',
                    ),
                    isLiked: false,
                    unread: true,
                  )
                : null))
        .toList();
  } on PlatformException catch (e) {
    print("Could not get chats data:\n\t${e}");
    return [];
  } on Error catch (e) {
    print("Error parsing chats:\n\t${e}");
    return [];
  }
}

Future<Chat> addChat(String id, String key) async {
  try {
    int status = await chats.invokeMethod('add', {"id": id, "key": key});
    if(status == 1) {
      print("Already member of chat");
      return null;
    }
    else {
      print("Joined chat");
      return new Chat(id: id, key: key, lastMessage: null);
    }
  } catch (e) {
    print(e);
    return null;
  }
}
