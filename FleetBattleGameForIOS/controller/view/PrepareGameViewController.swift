//
//  PrepareGameViewController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation

class PrepareGameViewController: ObservableObject, PrepareGameViewControllerInterface {
    
    @Published var showError = true
    @Published var errorMessage = ""
    @Published var game: FleetBattleGame?
    @Published var cells = [GridHelperObject]()
    @Published var width = 0
    @Published var height = 0
    @Published var fleetDescription = ""
    
    @Published var officialShipMap = [Int : Int]()
    @Published var currentShipMap = [Int : Int]()
    
    @Published var isGridValidAndConfirmed = false
    @Published var updateFailed = false
    @Published var isButtonSelectable = false
    
    private var modelController: PrepareGameModelController? = nil
    var gameDetails: FleetBattleGameDetails?
    
    func initViewController(game: FleetBattleGame) {
        self.game = game
        self.width = game.gridWidth
        self.height = game.gridHeight
        modelController = PrepareGameModelController(viewController: self)
        gameDetails = GameService.getFleetBattleGameById(id: game.gameDetailsId)
        cells = modelController!.initGridHelperObjects(width: game.gridWidth, height: game.gridHeight)
        officialShipMap = modelController!.getGameDetailsMap(gameDetails: gameDetails!)
        showFeedbackAfterClick(feedback: PlaceShipFeedback(gameConfig: [Int : Int](), currentShipMap: [Int : Int](), errorMessage: ""))
    }
    
    /// View -> Model
    func evaluateFleetBattleGameGrid() {
        modelController!.checkGridValidation(gameDetails: gameDetails!, cells: cells, onConfirm: true)
    }
    
    func gridPositionClicked(row: Int, column: Int) {
        var currentCell = cells.first {$0.position.row == row && $0.position.column == column}!
        let index = cells.firstIndex(of: currentCell)!
        currentCell.isShipSet = !currentCell.isShipSet
        self.cells[index] = currentCell
        modelController!.checkGridValidation(gameDetails: gameDetails!, cells: cells, onConfirm: false)
    }
    
    func generateRandomGrid() {
        cells = modelController!.getRandomPlacedShips(gameDetails: gameDetails!)
        modelController!.checkGridValidation(gameDetails: gameDetails!, cells: cells, onConfirm: false)
    }
    
    /// Model -> View
    func showErrorMessage(message: String) {
        self.errorMessage = message
        self.showError = true
    }
    
    func startGameActivity(game: FleetBattleGame) {
        self.game = game
        self.isGridValidAndConfirmed = true
    }
    
    func startGameResultActivity(game: FleetBattleGame) {
        self.game = game
        updateFailed = true
    }
    
    func setShipList(shipList: [Ship]) {
        let map = FleetBattleGame.toMap(fleetBattleGame: self.game!)
        let objectCopy = FleetBattleGame.toObject(map: map)!
        objectCopy.documentId = game!.documentId
        self.modelController?.saveGridInGame(shipList: shipList, gameDetails: self.gameDetails!, game: objectCopy)
    }
    
    func showFeedbackAfterClick(feedback: PlaceShipFeedback) {
        self.currentShipMap = feedback.currentShipMap
        var allShipsAreSet = true
        for element in gameDetails!.shipDetailList {
            if let value = feedback.currentShipMap[element.length] {
                if value != element.numberOfThisType {
                    allShipsAreSet = false
                }
            } else {
                allShipsAreSet = false
            }
        }
        
        if allShipsAreSet && feedback.gameConfig == feedback.currentShipMap {
            isButtonSelectable = true
        } else {
            isButtonSelectable = false
        }
        
        self.errorMessage = allShipsAreSet && feedback.gameConfig != feedback.currentShipMap ? "Ungültiger Schifftyp gefunden" : feedback.errorMessage
    }
    
}
