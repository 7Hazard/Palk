import UIKit
import Flutter
import NotificationExtension

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let messanger = (window?.rootViewController as! FlutterViewController).binaryMessenger
        Util.registerChannel(messanger)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication,
                              didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                              fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                              -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        var data: [String:Any] = [:]
        userInfo.forEach { data[$0 as! String] = $1 }
        Util.channel?.invokeMethod("notification", arguments: data)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension Util {
    static var channel: FlutterMethodChannel?
    static func registerChannel(_ binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "solutions.desati.palk",
            binaryMessenger: binaryMessenger
        )
        channel!.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if
                call.method == "read",
                let args = call.arguments as? Dictionary<String, Any>,
                let key = args["key"] as? String
            {
                do {
                    result(String(data: try read(key), encoding: .utf8))
                } catch {
                    result(FlutterError(code: "READERR", message: "could not read from '\(key)'", details: nil))
                }
            } else if
                call.method == "write",
                let args = call.arguments as? Dictionary<String, Any>,
                let key = args["key"] as? String,
                let str = args["data"] as? String,
                let data = str.data(using: .utf8)
            {
                do {
                    try write(key, data)
                } catch {
                    result(FlutterError(code: "WRITERR", message: "could not write to '\(key)'", details: nil))
                }
            } else if
                call.method == "delete",
                let args = call.arguments as? Dictionary<String, Any>,
                let key = args["key"] as? String
            {
                do {
                    try delete(key)
                    result(Bool(true))
                } catch {
                    result(FlutterError(code: "DELERR", message: "could not delete from '\(key)'", details: nil))
                }
            } else {
                result(FlutterError(code: "BADCALL", message: "no such method or bad args", details: nil))
            }
        })
    }
}
