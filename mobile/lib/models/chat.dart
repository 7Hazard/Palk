import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:palk/models/profile.dart';
import 'package:http/http.dart' as http;
import 'package:util/file.dart';

import 'chat_entry.dart';

typedef Future OnMessageFn(Chat chat, ChatEntry message);

class Chat {
  final String id;
  final String key;
  String name;
  DateTime updated;
  DateTime read;
  ChatEntry? latestEntry;

  Chat(
    this.id,
    this.key,
    this.name,
    this.updated,
    this.read, {
    this.latestEntry,
  });

  get file => "chat-${id}";
  static get chatsFile => "chats";

  get object {
    return {
      "id": id,
      "key": key,
      "name": name,
      "updated": updated.toUtc().toIso8601String(),
      "read": read.toUtc().toIso8601String(),
      "latestEntry": latestEntry?.object,
    };
  }

  get url {
    var encodedName = base64UrlEncode(utf8.encode(name));
    return "palk://chat?id=${id}&key=${key}&name=${encodedName}";
  }

  Future<void> copyUrlToClipboard() async {
    await Clipboard.setData(ClipboardData(text: url));
    print("Copied '${url}' to clipboard");
  }

  static Map<String, Chat>? cache;
  static Future<Map<String, Chat>> get all async {
    if (cache != null) return cache!;
    try {
      var json = await File.read(chatsFile);
      Map<String, dynamic> obj = jsonDecode(json);
      cache = Map.fromEntries(await Future.wait(obj.entries.map((kv) async =>
          MapEntry(
              kv.key,
              Chat(
                  kv.value["id"],
                  kv.value["key"],
                  kv.value["name"],
                  DateTime.parse(kv.value["updated"]),
                  DateTime.parse(kv.value["read"]),
                  latestEntry:
                      await ChatEntry.fromObject(kv.value["latestEntry"]))))));
    } catch (e) {
      print("Error parsing chats:\n\t${e}");
      cache = {};
    }
    return cache!;
  }

  static Future<void> saveAll() async {
    var chats = (await all).map((key, value) => MapEntry(key, value.object));
    var json = jsonEncode(chats);
    await File.write(chatsFile, json);
  }

  Future<void> save({ChatEntry? entry}) async {
    if (entry != null) {
      try {
        var entries = await this.entries;
        entries.add(entry);
        await saveEntries(entries);
      } catch (e) {
        print("Could not save chat entry:\n\t${e}");
      }
    }

    await saveAll();
  }

  static Future<Chat?> get(String id) async {
    return (await all)[id];
  }

  static Future<Chat> add(String id, String key, String name) async {
    var chat = await get(id);
    if (chat != null) return chat;

    chat = cache!.putIfAbsent(
        id,
        () => Chat(id, key, name, DateTime.now(), DateTime.now(),
            latestEntry: null));

    File.write(chat.file, "[]");
    saveAll();
    FirebaseMessaging.instance.subscribeToTopic(id);

    // Send join event
    var data = jsonEncode({
      "kind": "join",
      "time": DateTime.now().toUtc().toIso8601String(),
      "user": Profile.current!.object
    });
    chat.send(data).then((response) async {
      print("Join notification status: ${response.statusCode}");
    });

    return chat;
  }

  Future<void> remove() async {
    cache?.remove(id);
    File.delete("chat-${id}");
    saveAll();
    FirebaseMessaging.instance.unsubscribeFromTopic(id);

    // Send join event
    var data = jsonEncode({
      "kind": "leave",
      "time": DateTime.now().toUtc().toIso8601String(),
      "user": Profile.current!.object
    });
    send(data).then((response) {
      print("Leave notification status: ${response.statusCode}");
    });
  }

  Future<bool> sendMessage(String message) async {
    try {
      var data = jsonEncode({
        "kind": "message",
        "time": DateTime.now().toUtc().toIso8601String(),
        "message": {
          "from": Profile.current!.id,
          "content": message,
        }
      });
      var response = await send(data);
      return response.statusCode == 200;
    } catch (e) {
      print("Could not send message: ${e}");
      return false;
    }
  }

  Future<http.Response> send(String data) async {
    var encryptedData = await encrypt(data);
    var body = jsonEncode({"chat": id, "data": encryptedData});
    var url = Uri.parse('https://palk.7hazard.workers.dev/chat');
    var response = await http.post(url, body: body);
    return response;
  }

  Future<String> encrypt(String data) async {
    // Encrypt
    final algorithm = AesGcm.with256bits(nonceLength: 12);
    final secretKey = await algorithm.newSecretKeyFromBytes(utf8.encode(key));
    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(
      utf8.encode(data),
      secretKey: secretKey,
      nonce: nonce,
    );
    var encryptedData = base64Encode(secretBox.concatenation());
    return encryptedData;
  }

  /// Decrypts data using chat's key
  Future<String> decrypt(String data) async {
    final algorithm = AesGcm.with256bits(nonceLength: 12);
    final secretKey = await algorithm.newSecretKeyFromBytes(utf8.encode(key));
    var secretbox = SecretBox.fromConcatenation(base64Decode(data).toList(),
        nonceLength: algorithm.nonceLength,
        macLength: algorithm.macAlgorithm.macLength);
    var decryptedBytes =
        await algorithm.decrypt(secretbox, secretKey: secretKey);
    var decrypted = utf8.decode(decryptedBytes);
    return decrypted;
  }

  Future<List<ChatEntry>> get entries async {
    try {
      var json = await File.read(file);
      List<dynamic> jsonlist = jsonDecode(json);
      var messages = await Future.wait(
          jsonlist.map((msg) async => (await ChatEntry.fromObject(msg))!));
      return messages;
    } catch (e) {
      print("Could not get messages:\n\t${e}");
      return [];
    }
  }

  Future<void> saveEntries(List<ChatEntry> entries) async {
    var objects = entries.map((e) => e.object).toList();
    var json = jsonEncode(objects);
    await File.write(file, json);
  }

  static var onActivityHandlers = Set<OnMessageFn>();

  static void subscribeOnActivity(OnMessageFn fn) {
    onActivityHandlers.add(fn);
  }

  static void unsubscribeOnActivity(OnMessageFn fn) {
    onActivityHandlers.remove(fn);
  }

  void onChatEntry(ChatEntry message) {
    latestEntry = message;
    updated = message.time;
    onActivityHandlers.forEach((fn) {
      fn(this, message);
    });
  }
}
