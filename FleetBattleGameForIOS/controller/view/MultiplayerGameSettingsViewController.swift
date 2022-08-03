//
//  MultiplayerGameSettingsViewController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 05.01.22.
//  Copyright © 2022 FMA2. All rights reserved.
//

import Foundation

class MultiplayerGameSettingsViewController: ObservableObject, MultiplayerGameSettingsViewControllerInterface {
    
    @Published var chosenGameDetails = GameService.getFleetBattleGameById(id: "1") // Default
    @Published var isGameReserved = true
    @Published var isCreatingSucceeded = false
    @Published var newGameWithId: FleetBattleGame?
    @Published var isPresentingPopup = false
    @Published var allPlayerNames = [String]()
    @Published var filteredNames = [String]()
    
    private var modelController: MultiplayerGameSettingsModelController? = nil
    
    init() {
        modelController = MultiplayerGameSettingsModelController(viewController: self)
        modelController?.getOtherUsernames()
    }
    
    func setOtherUsernames(list: [User]) {
        allPlayerNames = list.map { element in element.username }.sorted()
    }
    
    func updateSucceed(game: FleetBattleGame) {
        newGameWithId = game
        isCreatingSucceeded = true
    }
    
    private func checkValidation(secondPlayerName: String) -> Bool {
        if !isGameReserved {
            return true
        } else if allPlayerNames.first(where: { user in user == secondPlayerName }) != nil {
            return true
        }
        return false
    }
    
    func createNewGame(secondPlayerName: String) {
        if checkValidation(secondPlayerName: secondPlayerName) {
            let dateString = DateTimeHelper.getCurrentDateAsString()
            let game = FleetBattleGame(
                fleetBattleGameDetails: chosenGameDetails,
                createdAt: dateString,
                mode: GameMode.MULTIPLAYER,
                playerName1: AuthenticationService.getUsername()!,
                difficultyLevel: nil
            )
            game.playerName2 = isGameReserved ? secondPlayerName : nil
            self.modelController!.saveNewGame(game: game)
        } else {
            isPresentingPopup = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.isPresentingPopup = false
            }
        }
    }


}


