import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
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
    void notification(dynamic args) async {
      var chatid = args["chat"];
      var chat = (await Chat.get(chatid))!;
      var data = jsonDecode(await chat.decrypt(args["data"]));

      var kind = data["kind"];
      var entry = ChatEntry(DateTime.parse(data["time"]), kind);

      switch (kind) {
        case "message":
          var message = data["message"];
          entry.message = Message(
            await Profile.get(message["from"]),
            message["content"],
          );
          break;
        case "join":
        case "leave":
          entry.kind = "event";
          var user = data["user"];
          var profile = await Profile.get(user["id"],
              name: user["name"], avatar: user["avatar"]);
          entry.event =
              "${profile.nameOrDefault()} ${kind == "join" ? "joined" : "left"}";
          break;
        default:
          return print("Unknown notification kind '${kind}'");
      }

      chat.onChatEntry(entry);
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

  static String randomString(int length) {
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random r = Random();
    return String.fromCharCodes(
        Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  static void snackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }
}
