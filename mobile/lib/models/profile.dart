import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/util.dart';

class Profile {
  final String id;
  String? name;
  String? avatar;

  Profile(this.id, {this.name, this.avatar});

  String nameOrDefault({String? def}) {
    if (name == null) {
      if (def == null)
        return id.substring(id.length - 10);
      else
        return def;
    } else
      return name!;
  }

  static MethodChannel channel = () {
    var channel = MethodChannel('solutions.desati.palk/profiles');
    return channel;
  }();

  static Map<String, Profile> cache = HashMap();
  static Future<Profile> get(String id, {String? name, String? avatar}) async {
    bool update = false;
    Profile? profile = cache[id];
    if (profile == null) {
      try {
        var json = jsonDecode(await read("profile-${id}"));
        profile = Profile(json["id"], name: json["name"], avatar: json["avatar"]);
      } catch (e) {
        print("No profile by id '${id}', creating");
        profile = Profile(id, name: name, avatar: avatar);
        update = true;
      }
    }
    if (update) await profile.save();
    return profile;
  }

  static Profile? current = null;

  Future<void> save() async {
    await write("profile-${id}", json);
  }

  dynamic get object {
    return {
      "id": id,
      "name": name,
      "avatar": avatar,
    };
  }

  String get json {
    return jsonEncode(object);
  }
}
