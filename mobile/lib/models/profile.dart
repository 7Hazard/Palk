import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/util.dart';

class Profile {
  final String id;
  final String name;
  final String avatar;

  Profile({
    this.id,
    this.name,
    this.avatar,
  });

  static Future<Map<String, Profile>> get all async {
    try {
      var json = await read("profiles");
      Map<String, dynamic> obj = jsonDecode(json)["profiles"];
      Map<String, Profile> profiles = {};
      obj.forEach((key, value) {
        profiles[key] = Profile(id: value["id"], name: value["name"]);
      });
      return profiles;
    } on Error catch (e) {
      print("Error parsing chats:\n\t${e}");
      return {};
    }
  }

  static MethodChannel channel = () {
    var channel = MethodChannel('solutions.desati.palk/profiles');
    return channel;
  }();

  static Future<Profile> get(String id) async {
    return (await all)[id];
  }

  static Future<Profile> set(String id, String name) async {
    try {
      int status = await channel.invokeMethod('set', {"id": id, "name": name});
      return Profile(id: id, name: name);
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

  static Profile current;
  static void setCurrent() async {
    current = await get(await FirebaseMessaging.instance.getToken());
    if (current == null) {
      print("PROFILE IS NULL");
      // TODO init
    }
  }
}
