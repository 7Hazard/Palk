package solutions.desati.palk

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "solutions.desati.palk"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
    }

//    channel = FlutterMethodChannel(
//    name: "solutions.desati.palk",
//    binaryMessenger: binaryMessenger
//    )
//    channel!.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//        if
//            call.method == "read",
//        let args = call.arguments as? Dictionary<String, Any>,
//        let key = args["key"] as? String
//        {
//            do {
//                result(String(data: try read(key), encoding: .utf8))
//                } catch {
//                    result(FlutterError(code: "READERR", message: "could not read from '\(key)'", details: nil))
//                }
//            } else if
//        call.method == "write",
//        let args = call.arguments as? Dictionary<String, Any>,
//        let key = args["key"] as? String,
//        let str = args["data"] as? String,
//        let data = str.data(using: .utf8)
//        {
//            do {
//                try write(key, data)
//                } catch {
//                    result(FlutterError(code: "WRITERR", message: "could not write to '\(key)'", details: nil))
//                }
//            } else if
//        call.method == "delete",
//        let args = call.arguments as? Dictionary<String, Any>,
//        let key = args["key"] as? String
//        {
//            do {
//                try delete(key)
//                    result(Bool(true))
//                } catch {
//                    result(FlutterError(code: "DELERR", message: "could not delete from '\(key)'", details: nil))
//                }
//            } else {
//            result(FlutterError(code: "BADCALL", message: "no such method or bad args", details: nil))
//        }
//    })
}
