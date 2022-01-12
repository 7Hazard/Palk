//
//  Message.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-04.
//

struct Message: Codable {
    let from: String
    let content: String
    let unread: Bool
}

struct ChatEntry: Codable {
    let time: String
    let kind: String
    let message: Message?
    
//    init(time: String, kind: String, message: Message) {
//        self.time = time
//        self.kind = kind
//        self.message = message
//    }
}
