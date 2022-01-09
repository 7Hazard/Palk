//
//  Profile.swift
//  Runner
//
//  Created by Leo Zaki on 2022-01-09.
//

import Foundation
import Flutter

class Profile: Codable {
    var id: String
    var name: String?
    
    init(id: String) {
        self.id = id
    }
}

class Profiles: Codable {
    /// UUID to Profile map
    var profiles: [String:Profile] = [:]
    
    static func json() throws -> Data {
        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.solutions.desati.palk")!
        let fileURL = dir.appendingPathComponent("profiles")
        return try Data(contentsOf: fileURL)
    }
    static func read() -> Profiles {
        do {
            return try JSONDecoder().decode(Profiles.self, from: try json())
        }
        catch {
            print("Could not read profiles file")
            return Profiles()
        }
    }
    func save() {
        if let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.solutions.desati.palk") {
            let fileURL = dir.appendingPathComponent("profiles")
            do {
                let data = try JSONEncoder().encode(self)
                try data.write(to: fileURL)
            }
            catch {
                print("Could not write to profiles file")
            }
        }
    }
    
    static var channel: FlutterMethodChannel?
    static func registerChannel(_ binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "solutions.desati.palk/profiles",
            binaryMessenger: binaryMessenger
        )
        channel!.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if(call.method == "getAll") {
                do {
                    result(String(data: try Profiles.json(), encoding: .utf8))
                } catch {
                    result(FlutterError(code: "READERR", message: "Could not read profiles data", details: nil))
                }
            } else if(call.method == "get"), let args = call.arguments as? Dictionary<String, Any>, let id = args["id"] as? String {
                do {
                    let profile = Profiles.read().profiles[id];
                    result(String(data: try JSONEncoder().encode(profile), encoding: .utf8))
                } catch {
                    result(FlutterError(code: "READERR", message: "Could not read profiles data", details: nil))
                }
            } else if call.method == "set", let args = call.arguments as? Dictionary<String, Any>, let id = args["id"] as? String {
                let profiles = Profiles.read()
                let profile = Profile(id: id)
                if let name = args["name"] as? String {
                    profile.name = name;
                }
                profiles.profiles[id] = profile
                profiles.save()
                result(Int(0))
            } else if call.method == "remove", let args = call.arguments as? Dictionary<String, Any>, let id = args["id"] as? String {
                let profiles = Profiles.read()
                profiles.profiles.removeValue(forKey: id)
                profiles.save()
                result(Int(0))
            } else {
                result(FlutterError(code: "BADCALL", message: "no such method or bad args", details: nil))
            }
        })
    }
}
