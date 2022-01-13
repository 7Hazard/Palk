//
//  Data.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-10.
//

import Foundation

class Util {
    static let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.solutions.desati.palk")!
    static func read(_ filename: String) throws -> Data {
        let fileURL = dir.appendingPathComponent(filename)
        return try Data(contentsOf: fileURL)
    }
    static func write(_ filename: String, _ data: Data) throws {
        let fileURL = dir.appendingPathComponent(filename)
        try data.write(to: fileURL)
    }
    static func delete(_ filename: String) throws {
        let fileURL = dir.appendingPathComponent(filename)
        try FileManager.default.removeItem(at: fileURL)
    }
}
