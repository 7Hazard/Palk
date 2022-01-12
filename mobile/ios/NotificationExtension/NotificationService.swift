//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by Leo Zaki on 2022-01-03.
//

import UserNotifications
import CryptoKit

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.body = "kind"
            let kind = bestAttemptContent.userInfo["kind"]! as! String
            if kind == "message" {
                do {
                    bestAttemptContent.body = "chatid" // these are for debugging
                    let chatid = bestAttemptContent.userInfo["chat"]! as! String
                    bestAttemptContent.body = "read chats"
                    let chats = try JSONDecoder().decode([String:Chat].self, from: Util.read("chats"))
                    if let chat = chats[chatid] {
                        let key = chat.key
                        
                        bestAttemptContent.body = "data"
                        let encryptedData = bestAttemptContent.userInfo["data"]! as! String
                        bestAttemptContent.body = "decrypt"
                        let decryptedContent = try decryptData(key, encryptedData)

                        struct MessageData: Decodable {
                            let time: String
                            let from: String
                            let content: String
                        }
                        bestAttemptContent.body = "json"
                        let data = try JSONDecoder().decode(
                            MessageData.self,
                            from: decryptedContent.data(using: .utf8)!
                        )

                        let entry = ChatEntry(
                            time: data.time,
                            kind: "message",
                            message: Message(
                                from: data.from,
                                content: data.content,
                                unread: true
                            )
                        )
                        chat.lastEntry = entry
                        chat.lastUpdate = entry.time
                        bestAttemptContent.body = "chats write"
                        try Util.write("chats", try JSONEncoder().encode(chats))
                        
                        bestAttemptContent.body = "messages read"
                        var messages = try JSONDecoder().decode([ChatEntry].self, from: try Util.read("chat-\(chatid)"))
                        messages.append(entry)
                        bestAttemptContent.body = "messages write"
                        try Util.write("chat-\(chatid)", try JSONEncoder().encode(messages));
                        
                        // finally
                        bestAttemptContent.title = chat.name
                        bestAttemptContent.body = data.content
                    } else {
                        bestAttemptContent.title = "Unknown chat"
                        bestAttemptContent.body = "Encrypted message"
                    }
                } catch {
                    bestAttemptContent.title = "Error"
                }
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

func decryptData(_ key: String, _ message: String) throws -> String {
    let key = SymmetricKey(data: key.data(using: .utf8)!)
    let data = Data(base64Encoded: message)!

    let nonce = data[0...11] // = initialization vector
    let tag = data[data.count-16...data.count-1]
    let ciphertext = data[12...data.count-17]

    let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce), ciphertext: ciphertext, tag: tag)

    let decryptedData = try AES.GCM.open(sealedBox, using: key)
    return String(decoding: decryptedData, as: UTF8.self)
}
