//
//  Ship.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

class Ship {
    let length: Int
    let orientation: Orientation
    let startPosition: Position
    var submerged: Bool = false
    init(length: Int, orientation: Orientation, startPosition: Position, submerged: Bool) {
        self.length = length
        self.orientation = orientation
        self.startPosition = startPosition
        self.submerged = submerged
    }

    func isPositionPartOfShip(pos: Position) -> Bool {
        return getAllPositionsOfShip().contains(where: { $0.column == pos.column && $0.row == pos.row})
    }

    func getAllPositionsOfShip() -> [Position] {
        var positions = [Position]()
        switch orientation {
            case Orientation.HORIZONTAL:
                for i in 0..<length {
                    positions += [Position(row: startPosition.row, column: startPosition.column + i)]
                }

            case Orientation.VERTICAL:
                for i in 0..<length {
                    positions += [Position(row: startPosition.row + i, column: startPosition.column)]
                }
        }

        return positions
    }

    func getLastPositionOfShip() -> Position {
        return orientation == Orientation.HORIZONTAL ? Position(row: startPosition.row, column: startPosition.column + length - 1) : Position(row: startPosition.row + length - 1, column: startPosition.column)
    }

    static func multipleToMap(ships: [Ship]) -> [[String: Any]] {
        var shipMap = [[String: Any]]()
        ships.forEach {
            ship in
            shipMap.append(Ship.toMap(ship: ship))
        }
        return shipMap
    }

    static func toMap(ship: Ship) -> [String: Any] {
        return ["length": ship.length, "orientation": ship.orientation.rawValue, "startPosition": Position.toMap(pos: ship.startPosition), "submerged": ship.submerged]
    }

    static func multipleToObject(map: [[String: Any]]) -> [Ship] {
        var shipMap = [Ship]()
        map.forEach {
            ship in
            shipMap.append(Ship.toObject(map: ship)!)
        }

        return shipMap
    }

    static func toObject(map: [String: Any]) -> Ship? {
        return Ship(
            length: map["length"] as! Int,
            orientation: Orientation(rawValue: map["orientation"]! as! String)!,
            startPosition: Position.toObject(map: map["startPosition"] as! [String: Any])!,
            submerged: map["submerged"] as! Bool
        )
    }
}

