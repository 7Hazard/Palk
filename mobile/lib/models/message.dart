import 'profile.dart';

class Message {
  final Profile sender;
  final DateTime time;
  final String content;
  final bool isLiked;
  final bool unread;

  Message({
    this.sender,
    this.time,
    this.content,
    this.isLiked,
    this.unread,
  });

  get object => {
        "from": sender.id,
        "time": time.toUtc().toIso8601String(),
        "content": content,
      };

  static Future<Message> fromObject(msg) async {
    if (msg == null) return null;
    try {
      var message = Message(
        sender: await Profile.get(msg["from"]),
        time: DateTime.parse(msg["time"]),
        content: msg["content"],
        unread: true,
      );
      return message;
    } catch (e) {
      print("Could not create from object ${e}");
      return null;
    }
  }

  @override
  String toString() {
    return "Message(content: ${content}, time: ${time}, from: ${sender.id})";
  }
}
