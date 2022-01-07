import 'dart:convert';

import 'package:flutter/services.dart';

import 'message_model.dart';
import 'user_model.dart';

class Chat {
  final String id;
  final String key;
  final Message lastMessage;
  final DateTime lastUpdate;

  Chat({
    this.id,
    this.key,
    this.lastMessage,
    this.lastUpdate,
  });

  static MethodChannel channel = () {
    var channel = MethodChannel('solutions.desati.palk/chats');
    channel.setMethodCallHandler((call) async {
      if (call.method == "notification") {
        print("notification");
        // var json = jsonDecode(call.arguments);
        // print("Notification: ${json}");
      }
    });
    return channel;
  }();

  static Future<List<Chat>> getAll() async {
    try {
      var json = await channel.invokeMethod('get');
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
                    : null,
                lastUpdate: value["lastUpdate"] != null
                    ? DateTime.parse(value["lastUpdate"])
                    : null,
              ))
          .toList();
    } on PlatformException catch (e) {
      print("Could not get chats data:\n\t${e}");
      return [];
    } on Error catch (e) {
      print("Error parsing chats:\n\t${e}");
      return [];
    }
  }

  static Future<Chat> add(String id, String key) async {
    try {
      int status = await channel.invokeMethod('add', {"id": id, "key": key});
      if (status == 1) {
        print("Already member of chat");
        return null;
      } else {
        print("Joined chat");
        return new Chat(id: id, key: key, lastMessage: null);
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<int> remove(String id) async {
    try {
      int status = await channel.invokeMethod('remove', {"id": id});
      return status;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
