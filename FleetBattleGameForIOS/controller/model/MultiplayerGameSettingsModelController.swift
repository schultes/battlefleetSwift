//
//  MultiplayerGameSettingsModelController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 05.01.22.
//  Copyright © 2022 FMA2. All rights reserved.
//

protocol MultiplayerGameSettingsViewControllerInterface {
    func setOtherUsernames(list: [User])
    func updateSucceed(game: FleetBattleGame)
}

class MultiplayerGameSettingsModelController {
    private let viewController: MultiplayerGameSettingsViewControllerInterface
    init(viewController: MultiplayerGameSettingsViewControllerInterface) {
        self.viewController = viewController
    }

    func saveNewGame(game: FleetBattleGame) {
        DatabaseService.saveFleetBattleGameObject(map: FleetBattleGame.toMap(fleetBattleGame: game)) {
            result, error in
            if let savedGame = result {
                self.viewController.updateSucceed(game: savedGame)
            }

            if let message = error {
                print("\(message)")
            }
        }
    }

    func getOtherUsernames() {
        DatabaseService.getOtherUsernames() {
            result, error in
            if let list = result {
                self.viewController.setOtherUsernames(list: list)
            }

            if let message = error {
                print("\(message)")
            }
        }
    }
}
