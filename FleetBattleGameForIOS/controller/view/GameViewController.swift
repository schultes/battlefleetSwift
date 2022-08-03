//
//  GameViewController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation

class GameViewController: ObservableObject, GameViewControllerInterface {
    
    @Published var game: FleetBattleGame?
    @Published var gameForResult: FleetBattleGame?
    
    @Published var gameDetails: FleetBattleGameDetails = GameService.getFleetBattleGameById(id: "1") // will be overwritten
    @Published var shipDetailList = [[Any]]() // 0: Name, 1: Length, 2: P1, 3: P2
    
    @Published var showGameResultView = false
    
    @Published var isGameBoardClickable = true
    @Published var snapshotListener: SnapshotListenerHelper
    
    @Published var statusText = ""
    @Published var crossHairPosition: Position? = nil
    
    private var modelController: GameModelController? = nil
    private var username = AuthenticationService.getUsername()!
    
    init() {
        snapshotListener = SnapshotListenerHelper()
        modelController = GameModelController(viewController: self)
    }
    
    func initViewController(game: FleetBattleGame) {
        gameDetails = GameService.getFleetBattleGameById(id: game.gameDetailsId)
        for shipDetails in gameDetails.shipDetailList {
            let list: [Any] = [shipDetails.name, shipDetails.length, shipDetails.numberOfThisType, shipDetails.numberOfThisType]
            shipDetailList.append(list)
        }
        self.game = game
        calculateShipCount()
        calculateAndSetStatusText(game: game, defaultText: nil)
        snapshotListener.startListening(id: game.documentId!) { receivedGame, error in
            self.modelController?.snapShotListener(game: receivedGame, error: error, listener: self.snapshotListener)
        }
        
    }
    
    func calculateAndSetStatusText(game: FleetBattleGame?, defaultText: String?) {
        if let currentGame = self.game {
            if defaultText == nil {
                if currentGame.playerName2 == nil {
                    statusText = "Warte bis 2. Spieler beitritt..."
                }
                else if currentGame.gridFromPlayer1 == nil || currentGame.gridFromPlayer2 == nil {
                    statusText = "Warte bis Schiffe platziert wurden..."
                }
                else if (GameService.isUserPlayer1(game: currentGame) && currentGame.usersTurn == 1) || (GameService.isUserPlayer2(game: currentGame) && currentGame.usersTurn == 2) {
                    statusText = "Du bist am Zug"
                }
                else {
                    statusText = "\(currentGame.playerName2!) ist am Zug"
                }
            } else {
                statusText = defaultText!
            }
        } else {
            statusText = ""
        }
    }

    
    // View -> Model
    func getGridToDraw() -> FleetBattleGrid {
        let username = AuthenticationService.getUsername()!
        if let currentUserTurnName = game!.usersTurn == 1 ? game!.playerName1 : game!.playerName2 {
            if username == currentUserTurnName {
                return modelController!.getGridFromPlayer(game: game!, player: username, other: true)
            } else {
                return modelController!.getGridFromPlayer(game: game!, player: username)
            }
        } else {
            return modelController!.getGridFromPlayer(game: game!, player: username, other: true)
        }
    }
    
    func calculateShipCount() {
        var newShipDetailList = [[Any]]()
        for shipDetails in gameDetails.shipDetailList {
            var numberOfP1 = 0
            var numberOfP2 = 0
            
            if let g1 = game!.gridFromPlayer1 {
                numberOfP1 = g1.ships.filter { ship in
                    ship.length == shipDetails.length && ship.submerged == false
                }.count
            } else {
                numberOfP1 = shipDetails.numberOfThisType
            }
            
            if let g2 = game!.gridFromPlayer2 {
                numberOfP2 = g2.ships.filter { ship in
                    ship.length == shipDetails.length && ship.submerged == false
                }.count
            } else {
                numberOfP2 = shipDetails.numberOfThisType
            }
            
            let list: [Any] = [shipDetails.name, shipDetails.length, numberOfP1, numberOfP2]
            newShipDetailList.append(list)
        }
        shipDetailList = newShipDetailList
    }
    
    func gridPositionClicked(row: Int, column: Int) {
        if isGameBoardClickable  {
            if let currentGame = game {
                let grid = getGridToDraw()
                let gameCopy = FleetBattleGame.toObject(map: FleetBattleGame.toMap(fleetBattleGame: currentGame))
                gameCopy!.documentId = currentGame.documentId!
                modelController?.onFieldClicked(game: gameCopy!, fleetField: grid.getField(pos: Position(row: row, column: column)), username: username)
                
            }
        }
    }
    
    
    // Model -> View
    func onGameUpdate(game: FleetBattleGame) {
        self.game = game
        self.calculateAndSetStatusText(game: self.game, defaultText: nil)
        calculateShipCount()
        
        if game.isFinished {
            snapshotListener.removeListener()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                self.showGameResult(game: game)
                return
            }
        } else {
            isGameBoardClickable = true
            if game.mode == GameMode.SINGLEPLAYER && game.usersTurn == 2 && modelController!.gameKi != nil {
                let gameCopy = FleetBattleGame.toObject(map: FleetBattleGame.toMap(fleetBattleGame: game))!
                gameCopy.documentId = game.documentId
                modelController!.gameKi!.updateGrid(fleetBattleGrid: gameCopy.gridFromPlayer1!)
                let field = gameCopy.gridFromPlayer1!.getField(pos: modelController!.gameKi!.getNextTurn(wasLastMoveByKI: gameCopy.lastMoveBy == game.playerName2))
                modelController!.onFieldClicked(game: gameCopy, fleetField: field, username: gameCopy.playerName2!)
            }
        }
    }
    
    func showMove(fleetBattleGame: FleetBattleGame) {
        if let oldGame = self.game {
            let lastHit = fleetBattleGame.lastFiredPosition!
            let gridToAttack = modelController!.getGridFromPlayer(game: oldGame, player: username, other: fleetBattleGame.lastMoveBy == username)
            
            var durationBeforeShowingMove = 0.1
            if oldGame.mode == GameMode.SINGLEPLAYER {
                if fleetBattleGame.lastMoveBy == oldGame.playerName2 && oldGame.lastMoveBy != oldGame.playerName2 { // first move of ki
                    durationBeforeShowingMove = 1.5
                } else if fleetBattleGame.lastMoveBy == oldGame.playerName2 {
                    durationBeforeShowingMove = 0.9
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + durationBeforeShowingMove) { // show old grid
                let currentUserTurn = oldGame.usersTurn == 1 ? oldGame.playerName1 : oldGame.playerName2
                let text = self.username == currentUserTurn ? "Feuer!" : "Gegner feuert!"
                self.calculateAndSetStatusText(game: oldGame, defaultText: text)
                self.crossHairPosition = lastHit
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { // show crosshair
                    self.crossHairPosition = nil
                    gridToAttack.fields[lastHit.row][lastHit.column].isVisible = true
                    let showResultDuration = fleetBattleGame.usersTurn == oldGame.usersTurn ? 1.0 : 1.5
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + showResultDuration) { // show result
                        self.onGameUpdate(game: fleetBattleGame)
                    }
                }
            }
        }
    }
    
    func showGameResult(game: FleetBattleGame) {
        snapshotListener.removeListener()
        self.gameForResult = game
        self.showGameResultView = true
    }
    
    
    
    
}
