//
//  Message.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-04.
//

struct Message: Codable {
    let from: String
    let content: String
}

struct ChatEntry: Codable {
    let time: String
    var kind: String
    var message: Message?
    var event: String?
}
