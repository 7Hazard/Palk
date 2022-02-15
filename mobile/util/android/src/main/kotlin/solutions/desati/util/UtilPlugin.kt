package solutions.desati.util

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.BufferedReader
import java.io.File
import android.content.Context

/** UtilPlugin */
class UtilPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context : Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "util")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "read") {
      var args = call.arguments as Map<String, Any>;
      var key = args["key"] as String;
      try {
        val bufferedReader: BufferedReader = File(context.filesDir, key).bufferedReader()
        val inputString = bufferedReader.use { it.readText() }
        result.success(inputString)
      } catch (e: Exception) {
        result.error("READERR", "could not read from '${key}'", null)
      }
    } else if (call.method == "write") {
      var args = call.arguments as Map<String, Any>;
      var key = args["key"] as String;
      var data = args["data"] as String;
      File(context.filesDir, key).printWriter().use { out ->
        out.print(data)
      }
      result.success(true)
    } else if (call.method == "delete") {
      var args = call.arguments as Map<String, Any>;
      var key = args["key"] as String;
      result.success(File(context.filesDir, key).delete())
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
