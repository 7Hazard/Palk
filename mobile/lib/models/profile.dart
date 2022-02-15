import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:palk/util.dart';
import 'package:util/file.dart';

class Profile {
  final String id;
  String? name;
  String? avatar;

  Profile(this.id, {this.name, this.avatar});

  String nameOrDefault({String? def}) {
    return name ?? def ?? id.substring(id.length - 10);
  }

  static MethodChannel channel = () {
    var channel = MethodChannel('solutions.desati.palk/profiles');
    return channel;
  }();

  static Map<String, Profile> cache = HashMap();
  static Future<Profile> getOrUpdate(String id,
      {String? name, String? avatar}) async {
    bool save = false;
    var profile = await get(id);
    if (profile == null) {
      print("Creating profile for '${id}'");
      profile = Profile(id, name: name, avatar: avatar);
      save = true;
    }
    // Check if name has changed
    if (name != null && profile.name != name) {
      profile.name = name;
      save = true;
    }
    // Check if avatar has changed
    if (avatar != null && profile.avatar != avatar) {
      profile.avatar = avatar;
      save = true;
    }
    if (save) await profile.save();
    return profile;
  }

  static Future<Profile?> get(String id) async {
    Profile? profile = cache[id];
    if (profile == null) {
      try {
        var json = jsonDecode(await File.read("profile-${id}"));
        profile =
            Profile(json["id"], name: json["name"], avatar: json["avatar"]);
      } catch (e) {
        print("No profile by id '${id}'");
      }
    }
    return profile;
  }

  static Profile? current = null;

  Future<void> save() async {
    await File.write("profile-${id}", json);
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
