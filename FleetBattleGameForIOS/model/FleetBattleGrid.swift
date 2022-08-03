//
//  FleetBattleGrid.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

class FleetBattleGrid: Grid {
    var width: Int
    var height: Int
    var fields = [[Field]]()
    var ownerUsername: String
    var ships = [Ship]()
    
    convenience init(fleetBattleGameDetails: FleetBattleGameDetails, width: Int, height: Int, fields: [[Field]] = [[Field]](), ownerUsername: String, ships: [Ship] = [Ship]()) {
        self.init(fleetBattleGameDetails: fleetBattleGameDetails)
        self.width = width
        self.height = height
        self.fields = fields
        self.ownerUsername = ownerUsername
        self.ships = ships
    }
    
    init(fleetBattleGameDetails: FleetBattleGameDetails) {
        self.width = fleetBattleGameDetails.gridWidth
        self.height = fleetBattleGameDetails.gridHeight
        ownerUsername = fleetBattleGameDetails.name
    }
    
    func getField(pos: Position) -> Field {
        return fields[pos.row][pos.column]
    }
    
    static func toMap(fleetBattleGrid: FleetBattleGrid) -> [String: Any] {
        return ["width": fleetBattleGrid.width, "height": fleetBattleGrid.height, "fields": FleetBattleField.multipleToMap(fleetBattleFields: fleetBattleGrid.fields), "ownerUsername": fleetBattleGrid.ownerUsername, "ships": Ship.multipleToMap(ships: fleetBattleGrid.ships)]
    }
    
    static func toObject(map: [String: Any], gameDetailsId: String) -> FleetBattleGrid? {
        let width = map["width"] as! Int
        let height = map["height"] as! Int
        let ships = Ship.multipleToObject(map: map["ships"] as! [[String: Any]])
        return FleetBattleGrid(fleetBattleGameDetails: GameService.getFleetBattleGameById(id: gameDetailsId), width: width, height: height, fields: FleetBattleField.multipleToObject(map: map["fields"] as! [[String: Any]], columnCount: width, rowCount: height, shipList: ships), ownerUsername: map["ownerUsername"] as! String, ships: ships)
    }
}
