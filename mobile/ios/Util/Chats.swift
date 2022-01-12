//
//  Chats.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-04.
//

class Chat: Codable {
    let id: String
    let key: String
    let name: String
    var lastUpdate: String?
    var lastEntry: ChatEntry?
}
