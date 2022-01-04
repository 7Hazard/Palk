//
//  Message.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-04.
//

import Foundation

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
        let fileURL = dir.appendingPathComponent("chats/\(chatid)")
        return try Data(contentsOf: fileURL)
    }
    static func saveAll(chatid: String, messages: [Message]) throws {
        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.solutions.desati.palk")!
        let fileURL = dir.appendingPathComponent("chats/\(chatid)")
        let data = try JSONEncoder().encode(messages)
        try data.write(to: fileURL)
    }
}
