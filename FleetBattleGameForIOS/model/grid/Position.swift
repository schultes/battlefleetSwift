//
//  Position.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

struct Position: Hashable {
    let row: Int
    let column: Int
    static func toMap(pos: Position) -> [String: Any] {
        return ["row": pos.row, "column": pos.column]
    }

    static func toObject(map: [String: Any]) -> Position? {
        return Position(row: map["row"] as! Int, column: map["column"] as! Int)
    }
}
