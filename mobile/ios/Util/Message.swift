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
}

func decryptData(_ key: String, _ message: String) throws -> String {
    let key = SymmetricKey(data: key.data(using: .utf8)!)
    let data = Data(base64Encoded: message)!

    let nonce = data[0...11] // = initialization vector
    let tag = data[data.count-16...data.count-1]
    let ciphertext = data[12...data.count-17]

    let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce), ciphertext: ciphertext, tag: tag)

    let decryptedData = try AES.GCM.open(sealedBox, using: key)
    return String(decoding: decryptedData, as: UTF8.self)
}
