//
//  GameSettingModelController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

protocol SingleplayerGameSettingsViewControllerInterface {
    func creationSucceed(game: FleetBattleGame)
}

class SingleplayerGameSettingsModelController {
    private let viewController: SingleplayerGameSettingsViewControllerInterface
    init(viewController: SingleplayerGameSettingsViewControllerInterface) {
        self.viewController = viewController
    }

    func saveNewGame(game: FleetBattleGame) {
        DatabaseService.saveFleetBattleGameObject(map: FleetBattleGame.toMap(fleetBattleGame: game)) {
            result, error in
            if let savedGame = result {
                self.viewController.creationSucceed(game: savedGame)
            }

            if let message = error {
                print("\(message)")
            }
        }
    }
}
