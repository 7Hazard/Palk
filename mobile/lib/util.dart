import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/models/chat.dart';
import 'package:flutter_chat_ui/models/message.dart';

Future<String> read(String key) async {
  return await channel.invokeMethod("read", {"key": key});
}

Future write(String key, String data) async {
  await channel.invokeMethod("write", {"key": key, "data": data});
}

MethodChannel channel = () {
  void message(dynamic args) async {
    var chatid = args["chat"];
    print(chatid);
    var chat = await Chat.get(chatid);
    var message = await chat.decryptMessage(args["data"]);
    chat.messageReceived(message);
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

  ;

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
