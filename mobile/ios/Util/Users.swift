//
//  Users.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-04.
//

import Foundation

class User: Codable {
    var name: String
    var avatar: String // Base64
}

class Users: Codable {
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
