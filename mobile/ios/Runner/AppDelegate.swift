import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        print("Printing chat messages")
        let chats = Chats.read()
        for chat in chats.chats {
            for message in chat.value {
                print("Message from \(message.from): \(message.content)")
            }
        }
        
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
        
        // Print message ID.
        //      if let messageID = userInfo[gcmMessageIDKey] {
        //        print("Message ID: \(messageID)")
        //      }
        
        // Print full message.
        //    print(userInfo)
        let kind = userInfo["kind"]! as! String
        print("Kind: \(kind)")
        
        if kind == "message" {
            let chat = userInfo["chat"]! as! String
            let sender = userInfo["sender"]! as! String
            let content = userInfo["content"]! as! String
            
            var chats = Chats.read()
            if chats.chats[chat] == nil { chats.chats[chat] = [] }
            chats.chats[chat]!.append(Chats.Message(from: sender, content: content))
            chats.save()
            
            print("Message from \(sender): \(content)")
            
//            if #available(iOS 10.0, *) {
//                let content = UNMutableNotificationContent()
//                content.title = sender
//                content.subtitle = "Hi"
//                content.sound = UNNotificationSound.default
//
//                // show this notification five seconds from now
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//                // choose a random identifier
//                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//                // add our notification request
//                UNUserNotificationCenter.current().add(request)
//            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

//@available(iOS 10, *)
//extension AppDelegate: UNUserNotificationCenterDelegate {
//  // Receive displayed notifications for iOS 10 devices.
//  override func userNotificationCenter(_ center: UNUserNotificationCenter,
//                              willPresent notification: UNNotification,
//                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
//                                -> Void) {
//    let userInfo = notification.request.content.userInfo
//
//    // With swizzling disabled you must let Messaging know about the message, for Analytics
//    // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//    // ...
//
//    // Print full message.
//    print(userInfo)
//
//    // Change this to your preferred presentation option
//    completionHandler([[.alert, .sound]])
//  }
//
//  override func userNotificationCenter(_ center: UNUserNotificationCenter,
//                              didReceive response: UNNotificationResponse,
//                              withCompletionHandler completionHandler: @escaping () -> Void) {
//    let userInfo = response.notification.request.content.userInfo
//
//    // ...
//
//    // With swizzling disabled you must let Messaging know about the message, for Analytics
//    // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//    // Print full message.
//    print(userInfo)
//
//    completionHandler()
//  }
//
//}

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

struct Users: Codable {
    struct User: Codable {
        var name: String
        var avatar: String // Base64
    }
    
    var users: [String:User] = [:]
    
    static func read() -> Users {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("chats")
            do {
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode(Users.self, from: data)
            }
            catch {
                print("Could not read logs file")
            }
        }
        return Users()
    }
    
    func save() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("users")
            do {
                let data = try JSONEncoder().encode(self)
                try data.write(to: fileURL)
            }
            catch {
                print("Could not write to users file")
            }
        }
    }
}

struct Chats: Codable {
    struct Message: Codable {
        var from: String
        var content: String
    }
    
    var chats: [String:[Message]] = [:]
    
    static func read() -> Chats {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("chats")
            do {
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode(Chats.self, from: data)
            }
            catch {
                print("Could not read chats file")
            }
        }
        return Chats()
    }
    func save() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("chats")
            do {
                let data = try JSONEncoder().encode(self)
                try data.write(to: fileURL)
            }
            catch {
                print("Could not write to chats file")
            }
        }
    }
}
