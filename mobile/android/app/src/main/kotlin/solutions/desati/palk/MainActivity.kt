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
//    , FlutterPlugin
//    , FirebaseMessagingService()
{

//    override fun onMessageReceived(remoteMessage: RemoteMessage) {
//        super.onMessageReceived(remoteMessage)
//
////        // Waking the screen for 5 seconds and disabling keyguard
////        val km = baseContext.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
////        val kl = km.newKeyguardLock("MyKeyguardLock")
////        kl.disableKeyguard()
////        val pm = baseContext.getSystemService(Context.POWER_SERVICE) as PowerManager
////        val wakeLock = pm.newWakeLock(PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE, TAG)
////        wakeLock.acquire(5000L)
////
////        // Create an intent to launch .MainActivity and start it as a NEW_TASK
////        val notificationIntent = Intent("android.intent.category.LAUNCHER")
////        notificationIntent
////            .setAction(Intent.ACTION_MAIN)
////            .setClassName("com.myapp", "com.myapp.MainActivity")
////            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
////        startActivity(notificationIntent)
//    }


    private val CHANNEL = "solutions.desati.palk"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
//        flutterEngine.plugins.add(this)
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

//    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//        MethodChannel(binding.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
//        }
//    }
//
//    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//        TODO("Not yet implemented")
//    }
}
