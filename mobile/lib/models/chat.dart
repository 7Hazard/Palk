import 'dart:collection';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_ui/models/profile.dart';
import 'package:flutter_chat_ui/util.dart';
import 'package:http/http.dart' as http;

import 'chat_entry.dart';

typedef Future OnMessageFn(Chat chat, ChatEntry message);

class Chat {
  final String id;
  final String key;
  String name;
  DateTime lastUpdate;
  ChatEntry? lastEntry;

  Chat(
    this.id,
    this.key,
    this.name,
    this.lastUpdate, {
    this.lastEntry,
  });

  get object {
    return {
      "id": id,
      "key": key,
      "name": name,
      "lastUpdate": lastUpdate.toUtc().toIso8601String(),
      "lastEntry": lastEntry?.object,
    };
  }

  static Map<String, Chat>? cache;
  static Future<Map<String, Chat>> get all async {
    if (cache != null) return cache!;
    try {
      var json = await read("chats");
      Map<String, dynamic> obj = jsonDecode(json);

      // obj.entries.map((kv) async => null);
      cache = Map.fromEntries(await Future.wait(obj.entries.map((kv) async =>
          MapEntry(
              kv.key,
              Chat(
                  kv.value["id"],
                  kv.value["key"],
                  kv.value["name"],
                  kv.value["lastUpdate"] != null
                      ? DateTime.parse(kv.value["lastUpdate"])
                      : DateTime.now(),
                  lastEntry:
                      await ChatEntry.fromObject(kv.value["lastEntry"]))))));
    } catch (e) {
      print("Error parsing chats:\n\t${e}");
      cache = {};
    }
    return cache!;
  }

  static void saveAll() async {
    var chats = (await all).map((key, value) => MapEntry(key, value.object));
    var json = jsonEncode(chats);
    await write("chats", json);
  }

  static Future<Chat?> get(String chatid) async {
    return (await all)[chatid];
  }

  static Future<Chat> add(String id, String key, String name) async {
    var chat = cache!.putIfAbsent(
        id, () => Chat(id, key, name, DateTime.now(), lastEntry: null));
    write("chat-${id}", "[]");
    saveAll();
    await FirebaseMessaging.instance.subscribeToTopic(id);
    return chat;
  }

  static Future<void> remove(String id) async {
    cache?.remove(id);
    delete("chat-${id}");
    saveAll();
    await FirebaseMessaging.instance.unsubscribeFromTopic(id);
  }

  Future<bool> sendMessage(String message) async {
    final algorithm = AesGcm.with256bits(nonceLength: 12);
    final secretKey = await algorithm.newSecretKeyFromBytes(utf8.encode(key!));
    final nonce = algorithm.newNonce();

    var data = jsonEncode({
      "time": DateTime.now().toUtc().toIso8601String(),
      "from": Profile.current!.id,
      "content": message,
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
        body: jsonEncode({"chat": id, "data": encryptedData}));
    return response.statusCode == 200;
  }

  /// Decrypts data using chat's key
  Future<String> decrypt(String data) async {
    final algorithm = AesGcm.with256bits(nonceLength: 12);
    final secretKey = await algorithm.newSecretKeyFromBytes(utf8.encode(key!));
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
      var json = await read("chat-${id}");
      List<dynamic> jsonlist = jsonDecode(json);
      var messages = await Future.wait(
          jsonlist.map((msg) async => (await ChatEntry.fromObject(msg))!));
      return messages;
    } catch (e) {
      print("Could not get messages:\n\t${e}");
      return [];
    }
  }

  static var onActivityHandlers = Set<OnMessageFn>();

  static void subscribeOnActivity(OnMessageFn fn) {
    onActivityHandlers.add(fn);
  }

  static void unsubscribeOnActivity(OnMessageFn fn) {
    onActivityHandlers.remove(fn);
  }

  void messageReceived(ChatEntry message) {
    lastEntry = message;
    lastUpdate = message.time;
    onActivityHandlers.forEach((fn) {
      fn(this, message);
    });
  }
}
