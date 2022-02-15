import 'package:flutter/services.dart';

MethodChannel channel = () {
  const channel = MethodChannel('util');
  // channel.setMethodCallHandler((call) async {
  //   switch (call.method) {
  //     default:
  //       print("Unknown call ${call.method}");
  //       throw MissingPluginException('No such method');
  //   }
  // });

  return channel;
}();
