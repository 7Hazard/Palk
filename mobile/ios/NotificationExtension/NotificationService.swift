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
            do {
                bestAttemptContent.title = "chatid" // these are for debugging
                let chatid = bestAttemptContent.userInfo["chat"]! as! String
                bestAttemptContent.title = "read chats"
                let chats = try JSONDecoder().decode([String:Chat].self, from: Util.read("chats"))
                if let chat = chats[chatid] {
                    let key = chat.key
                    
                    bestAttemptContent.title = "data"
                    let encryptedData = bestAttemptContent.userInfo["data"]! as! String
                    bestAttemptContent.title = "decrypt"
                    let decryptedContent = try decryptData(key, encryptedData)
                    
                    struct MessageData: Decodable {
                        let from: String
                        let content: String
                    }
                    struct UserData: Decodable {
                        let id: String
                        let name: String?
                        let avatar: String?
                    }
                    struct ChatData: Decodable {
                        let kind: String
                        let time: String
                        let message: MessageData?
                        let user: UserData?
                    }
                    bestAttemptContent.title = "json"
                    let data = try JSONDecoder().decode(
                        ChatData.self,
                        from: decryptedContent.data(using: .utf8)!
                    )
                    
                    var entry = ChatEntry(
                        time: data.time,
                        kind: data.kind
                    )
                    
                    if data.kind == "message", let messageData = data.message {
                        entry.message = Message(
                            from: messageData.from,
                            content: messageData.content
                        )
                        bestAttemptContent.body = messageData.content
                    }
                    else if data.kind == "join", let userData = data.user {
                        let name = userData.name ?? String(userData.id.suffix(10))
                        entry.kind = "event"
                        entry.event = "\(name) joined"
                        bestAttemptContent.body = entry.event!
                    }
                    else if data.kind == "leave", let userData = data.user {
                        let name = userData.name ?? String(userData.id.suffix(10))
                        entry.kind = "event"
                        entry.event = "\(name) left"
                        bestAttemptContent.body = entry.event!
                    }
                    else {
                        bestAttemptContent.body = "ERROR: Unknown data kind"
                    }
                    
                    // Finalize
                    chat.latestEntry = entry
                    chat.updated = entry.time
                    bestAttemptContent.title = "chats write"
                    try Util.write("chats", try JSONEncoder().encode(chats))
                    
                    bestAttemptContent.title = "messages read"
                    var entries = try JSONDecoder().decode([ChatEntry].self, from: try Util.read("chat-\(chatid)"))
                    entries.append(entry)
                    bestAttemptContent.title = "messages write"
                    try Util.write("chat-\(chatid)", try JSONEncoder().encode(entries));
                    
                    bestAttemptContent.title = chat.name
                    
                } else {
                    bestAttemptContent.title = "Unknown chat"
                    bestAttemptContent.body = "ERROR: Encrypted message"
                }
            } catch {
                bestAttemptContent.body = "Error"
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
