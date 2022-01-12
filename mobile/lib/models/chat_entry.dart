import 'message.dart';

class ChatEntry {
  final DateTime time;
  String kind;
  Message? message;
  String? event;

  ChatEntry(this.time, this.kind, {this.message, this.event});

  String get description {
    switch (kind) {
      case "message":
        return message?.content ?? "#1";
      case "event":
        return event ?? "#2";
      default:
        return "#0";
    }
  }

  get object => {
        "time": time.toUtc().toIso8601String(),
        "kind": kind,
        "message": message?.object,
        "event": event
      };

  static Future<ChatEntry?> fromObject(entry) async {
    if (entry == null) return null;
    try {
      var message = ChatEntry(
        DateTime.parse(entry["time"]),
        entry["kind"],
        message: await Message.fromObject(entry["message"]),
        event: entry["event"]
      );
      return message;
    } catch (e) {
      print("Could not create from object ${e}");
      return null;
    }
  }

  @override
  String toString() {
    return "ChatEntry(time: ${time}, kind: ${kind}, message: ${message}, event: ${event})";
  }
}
