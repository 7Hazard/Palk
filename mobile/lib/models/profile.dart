
import 'dart:convert';

import 'package:flutter/services.dart';

class Profile {
  final String id;
  final String name;
  final String avatar;

  Profile({
    this.id,
    this.name,
    this.avatar,
  });

  static MethodChannel channel = () {
    var channel = MethodChannel('solutions.desati.palk/profiles');
    return channel;
  }();

  static Future<List<Profile>> getAll() async {
    try {
      var json = await channel.invokeMethod('getAll');
      Map<String, dynamic> obj = jsonDecode(json)["profiles"];
      return obj.values
          .map((value) => Profile(
                id: value["id"],
                name: value["name"]
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

  static Future<Profile> get(String id) async {
    try {
      var json = await channel.invokeMethod('get', {"id": id});
      dynamic obj = jsonDecode(json);
      return Profile(id: obj["id"], name: obj["name"]);
    } on Error catch (e) {
      print("Error parsing profile:\n\t${e}");
      return null;
    }
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
}
