//
//  Chats.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-04.
//

import Foundation

class Chat: Codable {
    var id: String
    var key: String
    var lastMessage: Message?
    
    init(id: String, key: String) {
        self.id = id
        self.key = key
        self.lastMessage = nil
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
}
