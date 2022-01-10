import 'dart:collection';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/models/profile.dart';
import 'package:flutter_chat_ui/util.dart';
import 'package:http/http.dart' as http;

import 'message.dart';

typedef Future OnMessageFn(Chat chat, Message message);

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
    // channel.setMethodCallHandler((call) async {
    //   switch (call.method) {
    //     case "message":
    //       try {
    //         var chatid = call.arguments["id"];
    //         var data = jsonDecode(call.arguments["data"]);
    //         var message = Message(
    //             sender: await Profile.get(data["from"]),
    //             text: data["content"],
    //             time: DateTime.parse(data["time"]),
    //             unread: true,
    //             isLiked: false);
    //         onMessage[chatid](message);
    //       } catch (e, stacktrace) {
    //         print("Error: ${e}, ${stacktrace}");
    //       }
    //       break;
    //     default:
    //       print("Unknown call ${call.method}");
    //       throw MissingPluginException('No such method');
    //   }
    // });
    return channel;
  }();

  static Future<Map<String, Chat>> get all async {
    try {
      // var json = await channel.invokeMethod('get');
      var json = await read("chats");
      Map<String, dynamic> obj = jsonDecode(json)["chats"];
      var chats = HashMap<String, Chat>();
      obj.forEach((key, value) {
        chats[key] = Chat(
          id: value["id"],
          key: value["key"],
          lastMessage: value["lastMessage"] != null
              ? Message(
                  text: value["lastMessage"]["content"],
                  time: DateTime.parse(value["lastMessage"]["time"]),
                  sender: Profile(
                    id: "",
                    name: 'Mille',
                    avatar: 'assets/images/greg.jpg',
                  ),
                  isLiked: false,
                  unread: true,
                )
              : null,
          lastUpdate: value["lastUpdate"] != null
              ? DateTime.parse(value["lastUpdate"])
              : null,
        );
      });
      return chats;
    } on Error catch (e) {
      print("Error parsing chats:\n\t${e}");
      return {};
    }
  }

  static Future<Chat> get(String chatid) async {
    return (await all)[chatid];
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
        text: json["content"],
        time: DateTime.parse(json["time"]),
        unread: true,
        isLiked: false);
  }

  static var onMessageHandlers = Set<OnMessageFn>();

  void subscribeOnMessage(OnMessageFn fn) {
    onMessageHandlers.add(fn);
  }

  void unsubscribeOnMessage(OnMessageFn fn) {
    onMessageHandlers.remove(fn);
  }

  void messageReceived(Message message) {
    onMessageHandlers.forEach((fn) {
      fn(this, message);
    });
  }
}
