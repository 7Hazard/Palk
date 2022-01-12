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
    let kind: String
    let message: Message?
}
