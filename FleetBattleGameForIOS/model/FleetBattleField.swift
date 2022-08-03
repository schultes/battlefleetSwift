//
//  FleetBattleField.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

struct FleetBattleField: Field {
    
    var position: Position
    var isVisible: Bool
    let ship: Ship?
    
    init(ship: Ship?, position: Position, isVisible: Bool) {
        self.ship = ship
        self.position = position
        self.isVisible = isVisible
    }

    static func multipleToMap(fleetBattleFields: [[Field]]) -> [[String: Any]] {
        var fleetBattleFieldMap = [[String: Any]]()
        fleetBattleFields.forEach {
            fleetBattleFieldRow in
            fleetBattleFieldRow.forEach {
                fleetBattleFieldColumn in
                fleetBattleFieldMap.append(FleetBattleField.toMap(fleetBattleField: fleetBattleFieldColumn as! FleetBattleField))
            }
        }

        return fleetBattleFieldMap
    }

    static func toMap(fleetBattleField: FleetBattleField) -> [String: Any] {
        let shipObject: Any = fleetBattleField.ship != nil ? Ship.toMap(ship: fleetBattleField.ship!) : ""
        return ["position": Position.toMap(pos: fleetBattleField.position), "isVisible": fleetBattleField.isVisible, "ship": shipObject]
    }

    static func multipleToObject(map: [[String: Any]], columnCount: Int, rowCount: Int, shipList: [Ship]) -> [[Field]] {
        var fleetBattleFields2D = [[Field]]()
        var fleetBattleFields = [Field]()
        for element in map {
            fleetBattleFields.append(FleetBattleField.toObject(map: element, shipList: shipList)!)
        }

        for row in 0..<rowCount {
            var tempList = [Field]()
            for column in 0..<columnCount {
                tempList.append(fleetBattleFields[row * columnCount + column])
            }

            fleetBattleFields2D.append(tempList)
        }

        return fleetBattleFields2D
    }

    static func toObject(map: [String: Any], shipList: [Ship]) -> FleetBattleField? {
        var ship = map["ship"] as? String != "" ? Ship.toObject(map: map["ship"] as! [String: Any]) : nil
        let position = Position.toObject(map: map["position"] as! [String: Any])!
        if ship != nil {
            let referenceShip = shipList.first {
                element in
                element.isPositionPartOfShip(pos: position)
            }

            ship = referenceShip
        }

        return FleetBattleField(ship: ship, position: position, isVisible: map["isVisible"] as! Bool)
    }
}
