//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by Leo Zaki on 2022-01-03.
//

import UserNotifications
import CryptoKit

func decryptMessage(_ key: String, _ message: String) throws -> String {
    let key = SymmetricKey(data: key.data(using: .utf8)!)
    let data = Data(base64Encoded: message)!

    let nonce = data[0...11] // = initialization vector
    let tag = data[data.count-16...data.count-1]
    let ciphertext = data[12...data.count-17]

    let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce), ciphertext: ciphertext, tag: tag)

    let decryptedData = try AES.GCM.open(sealedBox, using: key)
    return String(decoding: decryptedData, as: UTF8.self)
}

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            
            let kind = bestAttemptContent.userInfo["kind"]! as! String
            
            if kind == "message" {
                struct MessageData: Decodable {
                    let from: String
                    let name: String
                    let content: String
                    let time: String
                }
                
                do {
                    let chatid = bestAttemptContent.userInfo["chat"]! as! String
                    let chats = Chats.read()
                    var chat = chats.chats[chatid]

                    let key = chat!.key
                    
                    // tmp in future chats will be guaranteed to exist
                    if chat == nil {
                        chat = Chat(id: chatid, key: key)
                        chats.chats[chatid] = chat
                    }
                    // tmp
                    
                    let encryptedData = bestAttemptContent.userInfo["data"]! as! String
                    let decryptedContent = try decryptMessage(key, encryptedData)

                    let data = try JSONDecoder().decode(
                        MessageData.self,
                        from: decryptedContent.data(using: .utf8)!
                    )

                    bestAttemptContent.title = data.name
                    bestAttemptContent.body = data.content

                    let message = Message(from: data.from, content: data.content, time: data.time)
                    chat?.lastMessage = message
                    chats.save()
                    
                    var messages = Message.all(chatid: chatid)
                    messages.append(message)
                    try Message.saveAll(chatid: chatid, messages: messages)
                } catch {
                    bestAttemptContent.title = "Error"
                    bestAttemptContent.body = "Could not decrypt"
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