//
//  GameResultViewController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation

class GameResultViewController: ObservableObject {
    
    @Published var headline = ""
    @Published var detailsStart = ""
    @Published var detailsMiddle = ""
    @Published var detailsEnd = ""
    
    @Published var singlePlayerDetails = ""
    
    @Published var imageName = "result_winner"
    
    func setStrings(game: FleetBattleGame) {
        if game.winner == nil {
            headline = "Ups!"
            detailsStart = "Das Spiel wurde leider abgebrochen"
            imageName = "result_quit"
            return
        // Player won
        } else if game.winner == AuthenticationService.getUsername() {
            headline = "Herzlichen Glückwunsch!"
            detailsStart = "Du hast gegen "
            detailsMiddle = getOtherUsername(game: game)
            detailsEnd = " gewonnen!"
            imageName = "result_winner"
        // Player lost
        } else {
            headline = "Schade!"
            detailsStart = "Du hast gegen "
            detailsMiddle = getOtherUsername(game: game)
            detailsEnd = " verloren!"
            imageName = "result_loser"
        }
        if let difficulty = game.difficultyLevel {
            singlePlayerDetails = "(Schwierigkeitsgrad: \(difficulty.rawValue))"
        }
    }
    
    func getOtherUsername(game: FleetBattleGame) -> String {
        if game.mode == GameMode.SINGLEPLAYER {
            return "die CPU"
        }
        return game.playerName1 == AuthenticationService.getUsername()! ? game.playerName2! : game.playerName1
    }
    
    
}
