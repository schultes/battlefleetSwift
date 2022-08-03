//
//  User.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

struct User {
    let documentId: String?
    let username: String
    static let COLLECTION_NAME: String = "users"
    static func toMap(user: User) -> [String: Any] {
        return ["username": user.username]
    }

    static func toObject(documentId: String?, map: [String: Any]) -> User? {
        return map["username"] == nil ? nil : User(documentId: documentId, username: map["username"]! as! String)
    }
}
