import 'util.dart';

class File {
  static Future<String> read(String key) async {
    return await channel.invokeMethod("read", {"key": key});
  }

  static Future<void> write(String key, String data) async {
    await channel.invokeMethod("write", {"key": key, "data": data});
  }

  static Future delete(String key) async {
    await channel.invokeMethod("delete", {"key": key});
  }
}
