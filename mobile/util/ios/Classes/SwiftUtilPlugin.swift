import Flutter
import UIKit
import Foundation

public class SwiftUtilPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "util", binaryMessenger: registrar.messenger())
        let instance = SwiftUtilPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if
            call.method == "read",
            let args = call.arguments as? Dictionary<String, Any>,
            let key = args["key"] as? String
        {
            do {
                result(String(data: try SwiftUtilPlugin.read(key), encoding: .utf8))
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
                try SwiftUtilPlugin.write(key, data)
            } catch {
                result(FlutterError(code: "WRITERR", message: "could not write to '\(key)'", details: nil))
            }
        } else if
            call.method == "delete",
            let args = call.arguments as? Dictionary<String, Any>,
            let key = args["key"] as? String
        {
            do {
                try SwiftUtilPlugin.delete(key)
                result(Bool(true))
            } catch {
                result(FlutterError(code: "DELERR", message: "could not delete from '\(key)'", details: nil))
            }
        } else {
            result(FlutterError(code: "BADCALL", message: "no such method or bad args", details: nil))
        }
    }
    
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
