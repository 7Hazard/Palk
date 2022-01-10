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
        Message.registerChannel(messanger)
        Chats.registerChannel(messanger)
        Profiles.registerChannel(messanger)
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
