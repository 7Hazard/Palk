//
//  Data.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-10.
//

import Foundation
import Flutter

class Util {
    static func read(_ filename: String) throws -> Data {
        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.solutions.desati.palk")!
        let fileURL = dir.appendingPathComponent(filename)
        return try Data(contentsOf: fileURL)
    }
    static func write(_ filename: String, _ data: Data) throws {
        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.solutions.desati.palk")
        let fileURL = dir!.appendingPathComponent(filename)
        try data.write(to: fileURL)
    }
    
    static var channel: FlutterMethodChannel?
    static func registerChannel(_ binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "solutions.desati.palk",
            binaryMessenger: binaryMessenger
        )
        channel!.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if
                call.method == "read",
                let args = call.arguments as? Dictionary<String, Any>,
                let key = args["key"] as? String
            {
                do {
                    result(String(data: try read(key), encoding: .utf8))
                } catch {
                    result(FlutterError(code: "READERR", message: "could not read from '\(key)'", details: nil))
                }
            } else if
                call.method == "write",
                let args = call.arguments as? Dictionary<String, Any>,
                let key = args["key"] as? String,
                let str = args["data"] as? String,
                let data = str.data(using: .utf8)
            {
                do {
                    try write(key, data)
                } catch {
                    result(FlutterError(code: "WRITERR", message: "could not write to '\(key)'", details: nil))
                }
            } else {
                result(FlutterError(code: "BADCALL", message: "no such method or bad args", details: nil))
            }
        })
    }
}
