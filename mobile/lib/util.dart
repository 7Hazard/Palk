import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/models/chat.dart';

import 'models/chat_entry.dart';
import 'models/message.dart';
import 'models/profile.dart';

class Util {
  static Future<String> read(String key) async {
    return await channel.invokeMethod("read", {"key": key});
  }

  static Future<void> write(String key, String data) async {
    await channel.invokeMethod("write", {"key": key, "data": data});
  }

  static Future delete(String key) async {
    await channel.invokeMethod("delete", {"key": key});
  }

  static MethodChannel channel = () {
    void message(dynamic args) async {
      var chatid = args["chat"];
      var chat = await Chat.get(chatid);
      var data = args["data"];
      var decrypted = await chat!.decrypt(data);
      var json = jsonDecode(decrypted);
      var entry = ChatEntry(DateTime.parse(json["time"]), "message",
          message: Message(
            await Profile.get(json["from"]),
            json["content"],
          ));
      chat.messageReceived(entry);
    }

    void notification(dynamic args) async {
      var kind = args["kind"];
      switch (kind) {
        case "message":
          message(args);
          break;
        default:
          return print("Unknown notification kind '${kind}'");
      }
    }

    var channel = MethodChannel('solutions.desati.palk');
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "notification":
          notification(call.arguments);
          break;
        default:
          print("Unknown call ${call.method}");
          throw MissingPluginException('No such method');
      }
    });
    return channel;
  }();
}
