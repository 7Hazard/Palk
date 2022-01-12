import 'profile.dart';

class Message {
  final Profile from;
  final String content;

  Message(this.from, this.content);

  get object => {
        "from": from.id,
        "content": content,
      };

  static Future<Message?> fromObject(msg) async {
    if (msg == null) return null;
    try {
      return Message(
        await Profile.get(msg["from"]),
        msg["content"],
      );
    } catch (e) {
      print("Could not create from object ${e}");
      return null;
    }
  }
}
