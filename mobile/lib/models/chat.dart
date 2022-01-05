
import 'message_model.dart';

class Chat {
  final String id;
  final String key;
  final Message lastMessage;

  Chat({
    this.id,
    this.key,
    this.lastMessage
  });
}
