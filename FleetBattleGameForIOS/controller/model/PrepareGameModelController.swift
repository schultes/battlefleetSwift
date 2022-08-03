//
//  PrepareGameModelController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

protocol PrepareGameViewControllerInterface {
    func showErrorMessage(message: String)
    func startGameActivity(game: FleetBattleGame)
    func startGameResultActivity(game: FleetBattleGame)
    func setShipList(shipList: [Ship])
    func showFeedbackAfterClick(feedback: PlaceShipFeedback)
}

class PrepareGameModelController {
    private let viewController: PrepareGameViewControllerInterface
    init(viewController: PrepareGameViewControllerInterface) {
        self.viewController = viewController
    }
    
    func initGridHelperObjects(width: Int, height: Int) -> [GridHelperObject] {
        var cells = [GridHelperObject]()
        for row in 0..<width {
            for column in 0..<height {
                let gridHelper = GridHelperObject(position: Position(row: row, column: column), isShipSet: false)
                cells.append(gridHelper)
            }
        }
        
        return cells
    }
    
    func getRandomPlacedShips(gameDetails: FleetBattleGameDetails) -> [GridHelperObject] {
        let cells = ShipPlacementService.getGridForKi(fleetBattleGameDetails: gameDetails)
        return cells.flatMap { $0 }
    }
    
    func getGameDetailsMap(gameDetails: FleetBattleGameDetails) -> [Int: Int] {
        var gameConfig = [Int: Int]()
        for shipDetails in gameDetails.shipDetailList {
            gameConfig[shipDetails.length] = shipDetails.numberOfThisType
        }
        
        return gameConfig
    }
    
    private func hasGridHelperShip(cells: [GridHelperObject], position: Position) -> Bool? {
        if let gridHelper = cells.first(where: { $0.position.column == position.column && $0.position.row == position.row }) {
            return gridHelper.isShipSet
        }
        return false
    }
    
    private func isEnoughSpaceAroundShip(ship: Ship, cells: [GridHelperObject], gridWidth: Int) -> Bool {
        if ship.orientation == Orientation.HORIZONTAL {
            let shipRow = ship.startPosition.row
            // column-index of last field of ship
            let lastCol = ship.startPosition.column + ship.length - 1
            
            // Iterate over the columns of the ship (horizontal)
            for j in ship.startPosition.column...lastCol {
                let position = Position(row: shipRow + 1, column: j)
                let helper = hasGridHelperShip(cells: cells, position: position)
                if gridWidth > shipRow + 1 && helper == true {
                    return false
                }
            }
            // Corner (right down & left down)
            let helper = hasGridHelperShip(cells: cells, position: Position(row: shipRow + 1, column: lastCol + 1))
            if (lastCol + 1 < gridWidth) && (shipRow + 1 < gridWidth) && helper == true {
                return false
            }
            
            let helper2 = hasGridHelperShip(cells: cells, position: Position(row: shipRow + 1, column: ship.startPosition.column - 1))
            if (ship.startPosition.column > 0) && (shipRow + 1 < gridWidth) && helper2 == true {
                return false
            }
        } else {
            let shipCol = ship.startPosition.column
            let lastRow = ship.startPosition.row + ship.length - 1
            for i in ship.startPosition.row...lastRow {
                let helper = hasGridHelperShip(cells: cells, position: Position(row: i, column: shipCol - 1))
                if shipCol > 0 && helper == true {
                    return false
                }
                
                let helper2 = hasGridHelperShip(cells: cells, position: Position(row: i, column: shipCol + 1))
                if gridWidth > shipCol + 1 && helper2 == true {
                    return false
                }
            }
            // Corner (right down & left down)
            let helper = hasGridHelperShip(cells: cells, position: Position(row: lastRow + 1, column: shipCol + 1))
            if (lastRow + 1 < gridWidth) && (shipCol + 1 < gridWidth - 1) && helper == true {
                return false
            }
            
            let helper2 = hasGridHelperShip(cells: cells, position: Position(row: lastRow + 1, column: shipCol - 1))
            if (lastRow + 1 < gridWidth) && (shipCol > 0) && helper2 == true {
                return false
            }
        }
        
        return true
    }
    
    private func getAllPositionsOfPossibleShip(cells: [GridHelperObject], gridWidth: Int, isHorizontal: Bool, startPosition: Position) -> [Position] {
        var positions = [startPosition]
        var i = startPosition.row
        var j = startPosition.column
        if isHorizontal {
            var position = Position(row: i, column: j + 1)
            var helper = hasGridHelperShip(cells: cells, position: position)
            while j + 1 < gridWidth && helper == true {
                positions += [Position(row: i, column: j + 1)]
                j += 1
                position = Position(row: i, column: j + 1)
                helper = hasGridHelperShip(cells: cells, position: position)
            }
        } else {
            var position = Position(row: i + 1, column: j)
            var helper = hasGridHelperShip(cells: cells, position: position)
            while i + 1 < gridWidth && helper == true {
                positions += [Position(row: i + 1, column: j)]
                i += 1
                position = Position(row: i + 1, column: j)
                helper = hasGridHelperShip(cells: cells, position: position)
            }
        }
        
        return positions
    }
    
    private func isFieldContainedInShip(shipList: [Ship], pos: Position) -> Bool {
        for item in shipList {
            if item.isPositionPartOfShip(pos: pos) {
                return true
            }
        }
        
        return false
    }
    
    private func checkIsHorizontal(cells: [GridHelperObject], row: Int, column: Int, gridWidth: Int) -> Bool {
        let position = Position(row: row, column: column + 1)
        let helper = hasGridHelperShip(cells: cells, position: position)
        if column + 1 < gridWidth && helper == true {
            return true
        }
        
        return false
    }
    
    func checkGridValidation(gameDetails: FleetBattleGameDetails, cells: [GridHelperObject], onConfirm: Bool) {
        var possibleMap = [Int: Int]()
        var shipList = [Ship]()
        let height = gameDetails.gridHeight
        let width = gameDetails.gridWidth
        let gameConfig = getGameDetailsMap(gameDetails: gameDetails)
        var errorMessageForImmediatelyFeedback = ""
        
        // Iterate over each field of grid
        for row in 0..<height {
            for column in 0..<width {
                let position = Position(row: row, column: column)
                let helper = hasGridHelperShip(cells: cells, position: position)
                // Ship part found: boolean is true and is not part of any other already found ship
                if helper == true && !isFieldContainedInShip(shipList: shipList, pos: Position(row: row, column: column)) {
                    let isHorizontal = checkIsHorizontal(cells: cells, row: row, column: column, gridWidth: width)
                    let positions = getAllPositionsOfPossibleShip(cells: cells, gridWidth: width, isHorizontal: isHorizontal, startPosition: Position(row: row, column: column))
                    let orientation = isHorizontal ? Orientation.HORIZONTAL : Orientation.VERTICAL
                    let ship = Ship(length: positions.count, orientation: orientation, startPosition: Position(row: row, column: column), submerged: false)
                    shipList += [ship]
                    if !isEnoughSpaceAroundShip(ship: ship, cells: cells, gridWidth: width) {
                        if onConfirm {
                            viewController.showErrorMessage(message: "Schiffe dürfen sich nicht berühren oder \n" + " diagonal angeordnet werden")
                            return
                        }
                        
                        errorMessageForImmediatelyFeedback = "Schiffe dürfen sich nicht berühren oder \n diagonal angeordnet werden"
                    }
                    
                    // Add in possibleMap
                    if possibleMap[positions.count] != nil {
                        possibleMap[positions.count] = possibleMap[positions.count]! + 1
                    } else {
                        possibleMap[positions.count] = 1
                    }
                    
                    // Is ship with this size and count allowed
                    if gameConfig[positions.count] == nil {
                        if onConfirm {
                            viewController.showErrorMessage(message: "Ungültiger Schifftyp\ngefunden")
                            return
                        }
                    } else if gameConfig[positions.count]! < possibleMap[positions.count]! {
                        let nameOfShip = (gameDetails.shipDetailList.first {element in element.length == positions.count})!.name
                        if onConfirm {
                            viewController.showErrorMessage(message: "Zu viele Schiffe vom Typ\n\(nameOfShip)")
                            return
                        }
                    }
                }
            }
        }
        
        if gameConfig == possibleMap {
            if onConfirm {
                viewController.showErrorMessage(message: "")
                viewController.setShipList(shipList: shipList)
            }
        } else {
            if onConfirm {
                viewController.showErrorMessage(message: "Es fehlen Schiffe")
            }
        }
        
        if !onConfirm {
            viewController.showFeedbackAfterClick(feedback: PlaceShipFeedback(gameConfig: gameConfig, currentShipMap: possibleMap, errorMessage: errorMessageForImmediatelyFeedback))
        }
    }
    
    private func createFields(shipList: [Ship], gameDetails: FleetBattleGameDetails) -> [[FleetBattleField]] {
        var fields = [[FleetBattleField]]()
        for row in 0..<gameDetails.gridHeight {
            var tempList = [FleetBattleField]()
            for column in 0..<gameDetails.gridWidth {
                let position = Position(row: row, column: column)
                var ship: Ship? = nil
                for element in shipList {
                    if element.isPositionPartOfShip(pos: position) {
                        ship = element
                        break
                    }
                }
                
                tempList.append(FleetBattleField(ship: ship, position: position, isVisible: false))
            }
            
            fields.append(tempList)
        }
        
        return fields
    }
    
    private func extractShipsFromGrid(gameDetails: FleetBattleGameDetails, cells: [GridHelperObject]) -> [Ship] {
        var shipList = [Ship]()
        let width = gameDetails.gridWidth
        let height = gameDetails.gridHeight
        for row in 0..<height {
            for column in 0..<width {
                let position = Position(row: row, column: column)
                let helper = hasGridHelperShip(cells: cells, position: position)
                // Ship part found: boolean is true and is not part of any other already found ship
                if helper == true && !isFieldContainedInShip(shipList: shipList, pos: Position(row: row, column: column)) {
                    let isHorizontal = checkIsHorizontal(cells: cells, row: row, column: column, gridWidth: width)
                    let positions = getAllPositionsOfPossibleShip(cells: cells, gridWidth: width, isHorizontal: isHorizontal, startPosition: Position(row: row, column: column))
                    let orientation = isHorizontal ? Orientation.HORIZONTAL : Orientation.VERTICAL
                    let ship = Ship(length: positions.count, orientation: orientation, startPosition: Position(row: row, column: column), submerged: false)
                    shipList.append(ship)
                }
            }
        }
        
        return shipList
    }
    
    
    
    private func generateGridForKi(gameDetails: FleetBattleGameDetails, name: String) -> FleetBattleGrid {
        let gridKi = getRandomPlacedShips(gameDetails: gameDetails)
        let shipListKi = extractShipsFromGrid(gameDetails: gameDetails, cells: gridKi)
        let fieldsKi = createFields(shipList: shipListKi, gameDetails: gameDetails)
        return FleetBattleGrid(fleetBattleGameDetails: gameDetails, width: gameDetails.gridWidth, height: gameDetails.gridHeight, fields: fieldsKi, ownerUsername: name, ships: shipListKi)
    }
    
    
    func saveGridInGame(shipList: [Ship], gameDetails: FleetBattleGameDetails, game: FleetBattleGame) {
        let fields = createFields(shipList: shipList, gameDetails: gameDetails)
        if let username = AuthenticationService.getUsername() {
            let grid = FleetBattleGrid(fleetBattleGameDetails: gameDetails, width: gameDetails.gridWidth, height: gameDetails.gridHeight, fields: fields, ownerUsername: username, ships: shipList)
            var changedAttribute = [String: Any]()
            if GameService.isUserPlayer1(game: game) {
                game.gridFromPlayer1 = grid
                changedAttribute["gridFromPlayer1"] = FleetBattleGrid.toMap(fleetBattleGrid: grid)
            } else {
                game.gridFromPlayer2 = grid
                changedAttribute["gridFromPlayer2"] = FleetBattleGrid.toMap(fleetBattleGrid: grid)
            }
            
            if game.mode == GameMode.SINGLEPLAYER {
                let nameForKI = "CPU"
                game.playerName2 = nameForKI
                game.gridFromPlayer2 = generateGridForKi(gameDetails: gameDetails, name: nameForKI)
                changedAttribute["playerName2"] = nameForKI
                changedAttribute["playerNames"] = [game.playerName1, nameForKI]
                changedAttribute["gridFromPlayer2"] = FleetBattleGrid.toMap(fleetBattleGrid: game.gridFromPlayer2!)
            }
            
            DatabaseService.updateFleetBattleGameObject(id: game.documentId!, map: changedAttribute) {
                errorMessage in
                if errorMessage == nil {
                    self.viewController.startGameActivity(game: game)
                } else {
                    self.viewController.startGameResultActivity(game: game)
                }
            }
        }
    }
}
