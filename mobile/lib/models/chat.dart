import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_ui/models/profile.dart';
import 'package:flutter_chat_ui/util.dart';
import 'package:http/http.dart' as http;

import 'message.dart';

typedef Future OnMessageFn(Chat chat, Message message);

class Chat {
  final String id;
  final String key;
  DateTime lastUpdate;
  Message lastMessage;

  Chat(
    this.id,
    this.key,
    this.lastUpdate, {
    this.lastMessage,
  });

  get object {
    return {
      "id": id,
      "key": key,
      "lastMessage": lastMessage != null ? lastMessage.object : null,
      "lastUpdate": lastUpdate.toUtc().toIso8601String()
    };
  }

  static Map<String, Chat> cache;
  static Future<Map<String, Chat>> get all async {
    if (cache != null) return cache;
    try {
      var json = await read("chats");
      Map<String, dynamic> obj = jsonDecode(json)["chats"];

      // obj.entries.map((kv) async => null);
      cache = Map.fromEntries(await Future.wait(obj.entries.map((kv) async =>
          MapEntry(
              kv.key,
              Chat(
                  kv.value["id"],
                  kv.value["key"],
                  kv.value["lastUpdate"] != null
                      ? DateTime.parse(kv.value["lastUpdate"])
                      : DateTime.now(),
                  lastMessage:
                      await Message.fromObject(kv.value["lastMessage"]))))));
      return cache;
    } catch (e) {
      print("Error parsing chats:\n\t${e}");
      return {};
    }
  }

  static void saveAll() async {
    var chats = (await all).map((key, value) => MapEntry(key, value.object));
    var json = jsonEncode({"chats": chats});
    await write("chats", json);
  }

  static Future<Chat> get(String chatid) async {
    return (await all)[chatid];
  }

  static Future<Chat> add(String id, String key) async {
    var chat = cache.putIfAbsent(
        id, () => Chat(id, key, DateTime.now(), lastMessage: null));
    write("chat-${id}", "[]");
    saveAll();
    await FirebaseMessaging.instance.subscribeToTopic(id);
    return chat;
  }

  static Future<void> remove(String id) async {
    cache.remove(id);
    delete("chat-${id}");
    saveAll();
    await FirebaseMessaging.instance.unsubscribeFromTopic(id);
  }

  Future<bool> sendMessage(String message) async {
    final algorithm = AesGcm.with256bits(nonceLength: 12);
    final secretKey = await algorithm.newSecretKeyFromBytes(utf8.encode(key));
    final nonce = algorithm.newNonce();

    var data = jsonEncode({
      "content": message,
      "from": Profile.current.id,
      "name": Profile.current.name,
      "time": DateTime.now().toUtc().toIso8601String()
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
    final secretKey = await algorithm.newSecretKeyFromBytes(utf8.encode(key));
    var secretbox = SecretBox.fromConcatenation(base64Decode(data).toList(),
        nonceLength: algorithm.nonceLength,
        macLength: algorithm.macAlgorithm.macLength);
    var decryptedBytes =
        await algorithm.decrypt(secretbox, secretKey: secretKey);
    var decrypted = utf8.decode(decryptedBytes);
    return decrypted;
  }

  Future<Message> decryptMessage(String data) async {
    var json = jsonDecode(await decrypt(data));
    return Message(
        sender: await Profile.get(json["from"]),
        content: json["content"],
        time: DateTime.parse(json["time"]),
        unread: true,
        isLiked: false);
  }

  Future<List<Message>> get messages async {
    try {
      var json = await read("chat-${id}");
      List<dynamic> jsonlist = jsonDecode(json);
      var messages = await Future.wait(
          jsonlist.map((msg) async => await Message.fromObject(msg)));
      return messages;
    } catch (e) {
      print("Could not get messages:\n\t${e}");
      return [];
    }
  }

  static var onMessageHandlers = Set<OnMessageFn>();

  static void subscribeOnMessage(OnMessageFn fn) {
    onMessageHandlers.add(fn);
  }

  static void unsubscribeOnMessage(OnMessageFn fn) {
    onMessageHandlers.remove(fn);
  }

  void messageReceived(Message message) {
    lastMessage = message;
    lastUpdate = message.time;
    saveAll();
    onMessageHandlers.forEach((fn) {
      fn(this, message);
    });
  }
}
