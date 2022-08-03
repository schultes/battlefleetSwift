//
//  OpenGamesModelController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

protocol OpenGamesViewControllerInterface {
    func setRunningGamesOfUser(list: [FleetBattleGame])
    func setOpenGameRequestsOfUser(list: [FleetBattleGame])
    func setOtherOpenGameRequestsOfUser(list: [FleetBattleGame])
    func updateSucceed(game: FleetBattleGame)
    func startGameResultActivity(game: FleetBattleGame)
}

class OpenGamesModelController {
    let viewController: OpenGamesViewControllerInterface
    init(viewController: OpenGamesViewControllerInterface) {
        self.viewController = viewController
    }

    func updatePlayer2(game: FleetBattleGame) {
        game.playerName2 = AuthenticationService.getUsername()!
        let changedAttributes: [String : Any] = ["playerName2": game.playerName2!, "playerNames": [game.playerName1, game.playerName2!]]
        DatabaseService.updateFleetBattleGameObject(id: game.documentId!, map: changedAttributes) {
            errorMessage in
            if errorMessage == nil {
                self.viewController.updateSucceed(game: game)
            } else {
                self.viewController.startGameResultActivity(game: game)
            }
        }
    }

    // Two players and one of them is me
    func loadRunningGamesOfUser() {
        DatabaseService.getAllRunningGamesFromUser() {
            result, error in
            if let list = result {
                self.viewController.setRunningGamesOfUser(list: list)
            }

            if let message = error {
                print("\(message)")
            }
        }
    }

    // My own open games
    func loadOpenGameRequestsOfUser() {
        DatabaseService.getAllOpenGameRequestsFromUser() {
            result, error in
            if let list = result {
                self.viewController.setOpenGameRequestsOfUser(list: list)
            }

            if let message = error {
                print("\(message)")
            }
        }
    }

    // Other open games
    func loadOtherOpenGameRequests() {
        DatabaseService.loadAllOpenFleetBattleGames() {
            result, error in
            if let list = result {
                self.viewController.setOtherOpenGameRequestsOfUser(list: list)
            }

            if let message = error {
                print("\(message)")
            }
        }
    }
}
