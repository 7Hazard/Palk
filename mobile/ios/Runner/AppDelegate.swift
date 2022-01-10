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
        
        do {
            let chatid = userInfo["chat"]! as! String
            let chats = Chats.read()
            let chat = chats.chats[chatid]
            let key = chat!.key
            
            let encryptedData = userInfo["data"]! as! String
            let decryptedData = try decryptData(key, encryptedData)
            Chats.channel!.invokeMethod("message", arguments: ["id": chatid, "data": decryptedData])
        } catch {
            print("Error")
        }
        
        var data: [String:Any] = [:]
        userInfo.forEach { data[$0 as! String] = $1 }
        Util.channel?.invokeMethod("notification", arguments: data)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
