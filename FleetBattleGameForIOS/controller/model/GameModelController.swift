//
//  GameModelController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

protocol GameViewControllerInterface {
    var isGameBoardClickable: Bool { get set }

    func onGameUpdate(game: FleetBattleGame)
    func showMove(fleetBattleGame: FleetBattleGame)
    func showGameResult(game: FleetBattleGame)
}

class GameModelController {
    private var viewController: GameViewControllerInterface
    init(viewController: GameViewControllerInterface) {
        self.viewController = viewController
    }

    private var currentGame: FleetBattleGame? = nil
    var gameKi: FleetBattleKI? = nil
    
    func getGridFromPlayer(game: FleetBattleGame, player: String, other: Bool = false) -> FleetBattleGrid {
        var grid: FleetBattleGrid?
        if other {
            grid = player == game.playerName1 ? game.gridFromPlayer2 : game.gridFromPlayer1
        } else {
            grid = player == game.playerName1 ? game.gridFromPlayer1 : game.gridFromPlayer2
        }
        // Set empty grid to show a grid with the needed size, even if it is not ready yet
        if grid == nil {
            grid = FleetBattleGrid(fleetBattleGameDetails: GameService.getFleetBattleGameById(id: game.gameDetailsId), width: game.gridWidth, height: game.gridHeight, ownerUsername: "")
            var fields = [[Field]]()
            for row in 0..<game.gridHeight {
                var tempList = [Field]()
                for column in 0..<game.gridWidth {
                    tempList.append(FleetBattleField(ship: nil, position: Position(row: row, column: column), isVisible: false))
                }

                fields.append(tempList)
            }

            grid!.fields = fields
        }

        return grid!
    }

    func onFieldClicked(game: FleetBattleGame, fleetField: Field, username: String) {
        if game.gridFromPlayer1 == nil || game.gridFromPlayer2 == nil {
            return
        }

        let currentUserTurn = game.usersTurn == 1 ? game.playerName1 : game.playerName2
        let enemyGrid = getGridFromPlayer(game: game, player: username, other: true)
        let hitField = enemyGrid.getField(pos: fleetField.position) as? FleetBattleField
        
        if username == currentUserTurn && hitField != nil && !hitField!.isVisible {
            viewController.isGameBoardClickable = false
            enemyGrid.fields[fleetField.position.row][fleetField.position.column].isVisible = true
            game.lastFiredPosition = fleetField.position
            game.lastMoveBy = username
            if let ship = hitField!.ship {
                let shipPositions = ship.getAllPositionsOfShip()
                var sub = true
                for pos in shipPositions {
                    if enemyGrid.getField(pos: pos).isVisible == false {
                        sub = false
                    }
                }

                ship.submerged = sub
                (enemyGrid.fields[fleetField.position.row][fleetField.position.column] as! FleetBattleField).ship?.submerged = sub
                var finished = true
                for enemyShip in enemyGrid.ships {
                    if !enemyShip.submerged {
                        finished = false
                    }
                }

                game.isFinished = finished
                if finished {
                    game.winner = username
                }
            } else {
                game.usersTurn = game.usersTurn == 1 ? 2 : 1
            }

            let gameMap = FleetBattleGame.toMap(fleetBattleGame: game)
            DatabaseService.updateFleetBattleGameObject(id: game.documentId!, map: gameMap) {
                error in
                if error != nil {
                    self.viewController.showGameResult(game: game)
                }
            }
        }
    }

    func snapShotListener(game: FleetBattleGame?, error: String?, listener: SnapshotListenerInterface) {
        if let receivedGame = game {
            if currentGame == nil { //Coming back to running game
                currentGame = receivedGame
                if receivedGame.mode == GameMode.SINGLEPLAYER {
                    gameKi = FleetBattleKI(difficultyLevel: receivedGame.difficultyLevel!, fleetBattleGrid: receivedGame.gridFromPlayer1!)
                }

                viewController.onGameUpdate(game: receivedGame)
                return
            }

            if receivedGame.isFinished && receivedGame.winner == nil { //Game canceled
                listener.removeListener()
                viewController.showGameResult(game: receivedGame)
                return
            }

            if receivedGame.playerName2 != nil && receivedGame.gridFromPlayer1 != nil && receivedGame.gridFromPlayer2 != nil && receivedGame.lastMoveBy != nil && receivedGame.lastFiredPosition != nil {
                viewController.showMove(fleetBattleGame: receivedGame)
            } else {
                viewController.onGameUpdate(game: receivedGame)
            }

            currentGame = receivedGame
        }

        if error != nil { // Game is canceled - go to result activity
            listener.removeListener()
            viewController.showGameResult(game: game ?? FleetBattleGame(fleetBattleGameDetails: GameService.getFleetBattleGameById(id: "1"), createdAt: "", mode: GameMode.MULTIPLAYER, playerName1: "", difficultyLevel: nil))
        }
    }
}
