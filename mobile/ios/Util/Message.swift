//
//  Message.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-04.
//

import Foundation
import CryptoKit
import Flutter

class Message: Codable {
    var from: String
    var content: String
    var time: String
    
    init(from: String, content: String, time: String) {
        self.from = from
        self.content = content
        self.time = time
    }
    
    static func all(chatid: String) -> [Message] {
        do {
            return try JSONDecoder().decode([Message].self, from: try allJson(chatid: chatid))
        }
        catch {
            print("Could not read messages")
            return []
        }
    }
    static func allJson(chatid: String) throws -> Data {
        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.solutions.desati.palk")!
        let fileURL = dir.appendingPathComponent("chat-\(chatid)")
        return try Data(contentsOf: fileURL)
    }
    static func saveAll(chatid: String, messages: [Message]) throws {
        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.solutions.desati.palk")!
        let fileURL = dir.appendingPathComponent("chat-\(chatid)")
        let data = try JSONEncoder().encode(messages)
        try data.write(to: fileURL)
    }
    
    static var channel: FlutterMethodChannel?
    static func registerChannel(_ binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "solutions.desati.palk/messages",
            binaryMessenger: binaryMessenger
        )
        channel!.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if let chatid = call.arguments as? String {
                do {
                    result(String(data: try Message.allJson(chatid: chatid), encoding: .utf8))
                } catch {
                    result(FlutterError(code: "READERR", message: "Could not read chats data", details: nil))
                }
            } else {
                result(FlutterError(code: "bad args", message: nil, details: nil))
            }
        })
    }
}

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
