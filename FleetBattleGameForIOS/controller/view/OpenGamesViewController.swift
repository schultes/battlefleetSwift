//
//  OpenGamesView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation

class OpenGamesViewController: ObservableObject, OpenGamesViewControllerInterface {
    
    @Published var listOfRunningGames = [FleetBattleGame]()
    @Published var listOfOwnOpenGames = [FleetBattleGame]()
    @Published var listOfOtherOpenGames = [FleetBattleGame]()
    
    @Published var isUpdateSucceeded = false
    @Published var newGameWithId: FleetBattleGame?
    
    @Published var updateFailed = false
    
    
    private var modelController: OpenGamesModelController? = nil
    
    init() {
        modelController = OpenGamesModelController(viewController: self)
        modelController?.loadRunningGamesOfUser()
        modelController?.loadOtherOpenGameRequests()
        modelController?.loadOpenGameRequestsOfUser()
    }
    
    func sorterForGames(this: FleetBattleGame, other: FleetBattleGame) -> Bool {
        let date1 = DateTimeHelper.getDateFromString(dateString: this.createdAt)
        let date2 = DateTimeHelper.getDateFromString(dateString: other.createdAt)
        return date1 < date2
    }
    
    func setPlayer2(game: FleetBattleGame) {
        modelController?.updatePlayer2(game: game)
    }

    // Model -> View
    func setRunningGamesOfUser(list: [FleetBattleGame]) {
        listOfRunningGames = list.sorted(by: sorterForGames)
    }
    
    func setOpenGameRequestsOfUser(list: [FleetBattleGame]) {
        listOfOwnOpenGames = list.sorted(by: sorterForGames)
    }
    
    func setOtherOpenGameRequestsOfUser(list: [FleetBattleGame]) {
        listOfOtherOpenGames = list.sorted(by: sorterForGames)
    }
    
    func updateSucceed(game: FleetBattleGame) {
        newGameWithId = game
        isUpdateSucceeded = true
    }
    
    func startGameResultActivity(game: FleetBattleGame) {
        newGameWithId = game
        updateFailed = true
    }
    
}
