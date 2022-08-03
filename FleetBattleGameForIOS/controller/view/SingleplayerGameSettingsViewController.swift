//
//  GameSettingViewController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation

class SingleplayerGameSettingsViewController: ObservableObject, SingleplayerGameSettingsViewControllerInterface {
    
    @Published var chosenDifficulty = DifficultyLevel.EASY
    @Published var chosenGameDetails = GameService.getFleetBattleGameById(id: "1") // Default
    
    @Published var isCreatingSucceeded = false
    @Published var newGameWithId: FleetBattleGame?
    
    private var modelController: SingleplayerGameSettingsModelController? = nil
    
    init() {
        modelController = SingleplayerGameSettingsModelController(viewController: self)
    }
    
    func createNewGame() {
        let dateString = DateTimeHelper.getCurrentDateAsString()
        
        let game = FleetBattleGame(fleetBattleGameDetails: chosenGameDetails, createdAt: dateString, mode: GameMode.SINGLEPLAYER, playerName1: AuthenticationService.getUsername()!, difficultyLevel: chosenDifficulty)
        self.modelController!.saveNewGame(game: game)
    }
    
    func creationSucceed(game: FleetBattleGame) {
        newGameWithId = game
        isCreatingSucceeded = true
    }
    
}
