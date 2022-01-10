//
//  Chats.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-04.
//

import Foundation
import Flutter

class Chat: Codable {
    var id: String
    var key: String
    var lastMessage: Message?
    var lastUpdate: String?
    
    init(id: String, key: String) {
        self.id = id
        self.key = key
    }
}

class Chats: Codable {
    /// UUID to Chat map
    var chats: [String:Chat] = [:]
    
    static func json() throws -> Data {
        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.solutions.desati.palk")!
        let fileURL = dir.appendingPathComponent("chats")
        return try Data(contentsOf: fileURL)
    }
    static func read() -> Chats {
        do {
            return try JSONDecoder().decode(Chats.self, from: try json())
        }
        catch {
            print("Could not read chats file")
            return Chats()
        }
    }
    func save() {
        if let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.solutions.desati.palk") {
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
    
    static var channel: FlutterMethodChannel?
    static func registerChannel(_ binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "solutions.desati.palk/chats",
            binaryMessenger: binaryMessenger
        )
        channel!.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if(call.method == "get") {
                do {
                    result(String(data: try Chats.json(), encoding: .utf8))
                } catch {
                    result(FlutterError(code: "READERR", message: "Could not read chats data", details: nil))
                }
            } else if call.method == "add" {
                if
                    let args = call.arguments as? Dictionary<String, Any>,
                    let id = args["id"] as? String,
                    let key = args["key"] as? String
                {
                    let chats = Chats.read()
                    if(chats.chats[id] != nil) {
                        result(Int(1))
                    } else {
                        chats.chats[id] = Chat(id: id, key: key)
                        chats.save()
                        result(Int(0))
                    }
                } else {
                    result(FlutterError(code: "bad args", message: nil, details: nil))
                }
            } else if call.method == "remove" {
                if let args = call.arguments as? Dictionary<String, Any> {
                    if let id = args["id"] as? String {
                        let chats = Chats.read()
                        chats.chats.removeValue(forKey: id)
                        chats.save()
                        
                        try? Util.delete("chat-\(id)")
                        
                        result(Int(0))
                    } else {
                        result(FlutterError(code: "bad args", message: nil, details: nil))
                    }
                } else {
                    result(FlutterError(code: "unknown method", message: nil, details: nil))
                }
            }
        })
    }
}
