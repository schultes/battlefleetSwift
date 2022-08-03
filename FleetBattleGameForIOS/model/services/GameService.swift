//
//  GameService.swift
//  FleetBattleGame
//
//  Created by FMA2 on 29.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

class GameService {
    
    static private let listOfShipsClassic = [ShipDetails(name: "Schlachtschiff", length: 5, numberOfThisType: 1), ShipDetails(name: "Kreuzer", length: 4, numberOfThisType: 2), ShipDetails(name: "Zerstörer", length: 3, numberOfThisType: 3), ShipDetails(name: "U-Boot", length: 2, numberOfThisType: 4)]
    static private let listOfShipsQuick = [ShipDetails(name: "Schlachtschiff", length: 5, numberOfThisType: 2), ShipDetails(name: "Kreuzer", length: 4, numberOfThisType: 1), ShipDetails(name: "Zerstörer", length: 3, numberOfThisType: 1)]
    static private let listOfShipsSmall = [ShipDetails(name: "Kreuzer", length: 3, numberOfThisType: 1), ShipDetails(name: "U-Boot", length: 2, numberOfThisType: 2), ShipDetails(name: "Minensucher", length: 1, numberOfThisType: 1)]
    
    static private let classic = FleetBattleGameDetails(id: "1", name: "Klassik", gridWidth: 10, gridHeight: 10, shipDetailList: listOfShipsClassic)
    static private let quick = FleetBattleGameDetails(id: "2", name: "Schnell", gridWidth: 7, gridHeight: 7, shipDetailList: listOfShipsQuick)
    static private let small = FleetBattleGameDetails(id: "3", name: "Klein", gridWidth: 5, gridHeight: 5, shipDetailList: listOfShipsSmall)
    
    static let listOfAllGameModes = [classic, quick, small]
    
    static func getFleetBattleGameById(id: String) -> FleetBattleGameDetails {
        if let value = listOfAllGameModes.first(where: { element in element.id == id }) {
            return value
        }
        return classic
    }

    static func isUserPlayer1(game: Game) -> Bool {
        if let username = AuthenticationService.getUsername() {
            return game.playerName1 == username
        }
        return false
    }
    
    static func isUserPlayer2(game: Game) -> Bool {
        if let username = AuthenticationService.getUsername() {
            if let p2 = game.playerName2 {
                return username == p2
            }
        }
        return false
    }

    static func isOwnGridSet(game: FleetBattleGame) -> Bool {
        let currentPlayer = isUserPlayer1(game: game)
        if currentPlayer {
            if game.gridFromPlayer1 != nil {
                return true
            }
        } else {
            if game.gridFromPlayer2 != nil {
                if isUserPlayer2(game: game) {
                    return true
                }
            }
        }
        return false
    }
}
