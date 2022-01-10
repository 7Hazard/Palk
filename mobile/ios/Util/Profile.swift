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
    var avatar: String? // Base64
    
    init(id: String) {
        self.id = id
    }
    
    static func read(_ id: String) throws -> Profile? {
        return try JSONDecoder().decode(self, from: try Util.read("profile-\(id)"))
    }
    
    func save() {
        try? Util.write("profile-\(id)", JSONEncoder().encode(self)) 
    }
}
