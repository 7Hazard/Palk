import 'message.dart';

class ChatEntry {
  final DateTime time;
  final String kind;
  final Message? message;

  ChatEntry(this.time, this.kind, {this.message = null});

  String get description {
    switch (kind) {
      case "message":
        return message?.content ?? "#1";
      default:
        return "#0";
    }
  }

  get object => {
        "time": time.toUtc().toIso8601String(),
        "kind": kind,
        "message": message?.object
      };

  static Future<ChatEntry?> fromObject(entry) async {
    if (entry == null) return null;
    try {
      var message = ChatEntry(
        DateTime.parse(entry["time"]),
        entry["kind"],
        message: await Message.fromObject(entry["message"]),
      );
      return message;
    } catch (e) {
      print("Could not create from object ${e}");
      return null;
    }
  }

  @override
  String toString() {
    return "ChatEntry(time: ${time})";
  }
}
