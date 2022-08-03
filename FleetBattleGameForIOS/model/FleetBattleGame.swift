//
//  FleetBattleGame.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

class FleetBattleGame: Game, Serializable {
    
    var createdAt: String
    var mode: GameMode
    var playerName1: String
    var difficultyLevel: DifficultyLevel? = nil
    var documentId: String? = nil
    let gameDetailsId: String
    var gridFromPlayer1: FleetBattleGrid? = nil
    var gridFromPlayer2: FleetBattleGrid? = nil
    var lastFiredPosition: Position? = nil
    var gridHeight: Int
    var gridWidth: Int
    var playerName2: String? = nil
    var isFinished: Bool = false
    var winner: String? = nil
    var usersTurn: Int
    var lastMoveBy: String? = nil
    
    convenience init(
        fleetBattleGameDetails: FleetBattleGameDetails,
        createdAt: String,
        gridHeight: Int,
        gridWidth: Int,
        mode: GameMode,
        playerName1: String,
        playerName2: String?,
        isFinished: Bool,
        winner: String?,
        usersTurn: Int,
        difficultyLevel: DifficultyLevel?,
        lastMoveBy: String?,
        gridFromPlayer1: FleetBattleGrid?,
        gridFromPlayer2: FleetBattleGrid?,
        lastFiredPosition: Position?
    ) {
        self.init(fleetBattleGameDetails: fleetBattleGameDetails, createdAt: createdAt, mode: mode, playerName1: playerName1, difficultyLevel: difficultyLevel)
        self.createdAt = createdAt
        self.gridHeight = gridHeight
        self.gridWidth = gridWidth
        self.mode = mode
        self.playerName1 = playerName1
        self.playerName2 = playerName2
        self.isFinished = isFinished
        self.winner = winner
        self.usersTurn = usersTurn
        self.difficultyLevel = difficultyLevel
        self.lastMoveBy = lastMoveBy
        self.gridFromPlayer1 = gridFromPlayer1
        self.gridFromPlayer2 = gridFromPlayer2
        self.lastFiredPosition = lastFiredPosition
    }

    init(
        fleetBattleGameDetails: FleetBattleGameDetails,
        createdAt: String,
        mode: GameMode,
        playerName1: String,
        difficultyLevel: DifficultyLevel?
    ) {
        self.createdAt = createdAt
        self.mode = mode
        self.playerName1 = playerName1
        self.difficultyLevel = difficultyLevel
        gameDetailsId = fleetBattleGameDetails.id
        gridHeight = fleetBattleGameDetails.gridHeight
        gridWidth = fleetBattleGameDetails.gridWidth
        usersTurn = TPRandom.int(from: 1, to: 3)
    }

    static let COLLECTION_NAME: String = "fleetBattleGames"
    
    static func toObject(map: [String: Any]) -> FleetBattleGame? {
        let playername2Object = map["playerName2"] as? String != "" ? map["playerName2"]! : nil
        let winnerObject = map["winner"] as? String != "" ? map["winner"]! : nil
        let difficultyLevelObject = map["difficultyLevel"] as? String != "" ? DifficultyLevel(rawValue: map["difficultyLevel"]! as! String)! : nil
        let gridFromPlayer1Object = map["gridFromPlayer1"] as? String != "" ? FleetBattleGrid.toObject(map: map["gridFromPlayer1"] as! [String: Any], gameDetailsId: map["gameDetailsId"] as! String) : nil
        let gridFromPlayer2Object = map["gridFromPlayer2"] as? String != "" ? FleetBattleGrid.toObject(map: map["gridFromPlayer2"] as! [String: Any], gameDetailsId: map["gameDetailsId"] as! String) : nil
        let lastFiredPositionObject = map["lastFiredPosition"] as? String != "" ? Position.toObject(map: map["lastFiredPosition"] as! [String: Any]) : nil
        let lastMoveByObject = map["lastMoveBy"] as? String != "" ? map["lastMoveBy"]! : nil
                
        return map["createdAt"] == nil ||
            map["gridHeight"] == nil ||
            map["gridWidth"] == nil ||
            map["mode"] == nil ||
            map["playerName1"] == nil ||
            map["usersTurn"] == nil ||
            map["isFinished"] == nil ? nil :
            
            FleetBattleGame(
                fleetBattleGameDetails: GameService.getFleetBattleGameById(id: map["gameDetailsId"] as! String),
                createdAt: map["createdAt"] as! String,
                gridHeight: map["gridHeight"] as! Int,
                gridWidth: map["gridWidth"] as! Int,
                mode: GameMode(rawValue: map["mode"]! as! String)!,
                playerName1: map["playerName1"] as! String,
                playerName2: playername2Object as! String?,
                isFinished: map["isFinished"] as! Bool,
                winner: winnerObject as! String?,
                usersTurn: map["usersTurn"]! as! Int,
                difficultyLevel: difficultyLevelObject,
                lastMoveBy: lastMoveByObject as! String?,
                gridFromPlayer1: gridFromPlayer1Object,
                gridFromPlayer2: gridFromPlayer2Object,
                lastFiredPosition: lastFiredPositionObject
        )
    }

    static func toMap(fleetBattleGame: FleetBattleGame) -> [String: Any] {
        let playernameObject = fleetBattleGame.playerName2 != nil ? fleetBattleGame.playerName2! : ""
        let winnerObject = fleetBattleGame.winner != nil ? fleetBattleGame.winner! : ""
        let lastMoveByObject = fleetBattleGame.lastMoveBy != nil ? fleetBattleGame.lastMoveBy! : ""
        let difficultyLevelObject: Any = fleetBattleGame.difficultyLevel != nil ? fleetBattleGame.difficultyLevel!.rawValue : ""
        let gridFromPlayer1Object: Any = fleetBattleGame.gridFromPlayer1 != nil ? FleetBattleGrid.toMap(fleetBattleGrid: fleetBattleGame.gridFromPlayer1!) : ""
        let gridFromPlayer2Object: Any = fleetBattleGame.gridFromPlayer2 != nil ? FleetBattleGrid.toMap(fleetBattleGrid: fleetBattleGame.gridFromPlayer2!) : ""
        let lastFiredPositionObject: Any = fleetBattleGame.lastFiredPosition != nil ? Position.toMap(pos: fleetBattleGame.lastFiredPosition!) : ""
        
        return [
            "createdAt": fleetBattleGame.createdAt,
            "gridHeight": fleetBattleGame.gridHeight,
            "gridWidth": fleetBattleGame.gridWidth,
            "mode": fleetBattleGame.mode.rawValue,
            "playerName1": fleetBattleGame.playerName1,
            "playerName2": playernameObject,
            "playerNames": [fleetBattleGame.playerName1, playernameObject],
            "isFinished": fleetBattleGame.isFinished,
            "winner": winnerObject,
            "usersTurn": fleetBattleGame.usersTurn,
            "difficultyLevel": difficultyLevelObject,
            "lastMoveBy": lastMoveByObject,
            "gameDetailsId": fleetBattleGame.gameDetailsId,
            "gridFromPlayer1": gridFromPlayer1Object,
            "gridFromPlayer2": gridFromPlayer2Object,
            "lastFiredPosition": lastFiredPositionObject
        ]
    }
}
