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
                Message.channel!.invokeMethod("notification", arguments: try decryptData(key, encryptedData))
            } catch {
                print("Error")
            }
    
            completionHandler(UIBackgroundFetchResult.newData)
        }
}

func printLogs() {
    print("Printing logs:")
    for line in readLogs().background {
        print(line)
    }
}

struct Logs : Codable {
    var background: [String] = []
}

func readLogs() -> Logs {
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent("logs")
        //reading
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(Logs.self, from: data)
        }
        catch {
            print("Could not read logs file")
        }
    }
    return Logs()
}

func addLog(line: String) {
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent("logs")
        do {
            var logs = readLogs()
            logs.background.append(line)
            let data = try JSONEncoder().encode(logs)
            try data.write(to: fileURL)
        }
        catch {
            print("Could not read logs file")
        }
    }
}
