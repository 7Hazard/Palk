package solutions.desati.palk

import androidx.annotation.NonNull
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File

class MainActivity : FlutterActivity()
{
    private val CHANNEL = "solutions.desati.palk"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "read") {
//                var args = call.arguments as Map<String, Any>;
//                var key = args["key"] as String;
//                try {
//                    val bufferedReader: BufferedReader = File(context.filesDir, key).bufferedReader()
//                    val inputString = bufferedReader.use { it.readText() }
//                    result.success(inputString)
//                } catch (e: Exception) {
//                    result.error("READERR", "could not read from '${key}'", null)
//                }
//            } else if (call.method == "write") {
//                var args = call.arguments as Map<String, Any>;
//                var key = args["key"] as String;
//                var data = args["data"] as String;
//                File(context.filesDir, key).printWriter().use { out ->
//                    out.print(data)
//                }
//                result.success(true)
//            } else if (call.method == "delete") {
//                var args = call.arguments as Map<String, Any>;
//                var key = args["key"] as String;
//                result.success(File(context.filesDir, key).delete())
//            } else {
//                result.notImplemented()
//            }
            result.notImplemented()
        }
    }
}
