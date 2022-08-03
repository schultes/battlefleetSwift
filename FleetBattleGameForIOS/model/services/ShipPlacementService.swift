//
//  ShipPlacementService.swift
//  FleetBattleGame
//
//  Created by FMA2 on 30.12.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

class ShipPlacementService {
    static private var grid = [[GridHelperObject]]()
    static private var dummyShipList = [ShipHelperObject]()
    static private var gridWidth = 0
    static private var gridHeight = 0


    // Init data
    private static func initData(fleetBattleGameDetails: FleetBattleGameDetails) {
        gridWidth = fleetBattleGameDetails.gridWidth
        gridHeight = fleetBattleGameDetails.gridHeight
        grid = [[GridHelperObject]]()

        for i in 0..<gridHeight {
            var rowList = [GridHelperObject]()
            for j in 0..<gridWidth {
                rowList.append(GridHelperObject(position: Position(row: i, column: j), isShipSet: false))
            }
            grid.append(rowList)
        }

        // Init ships with random orientation
        dummyShipList.removeAll()
        for shipType in fleetBattleGameDetails.shipDetailList {
            for _ in 0..<shipType.numberOfThisType {
                let randomNumber = TPRandom.int(from: 0, to: 2)
                let randomOrientation = randomNumber == 0 ? Orientation.HORIZONTAL : Orientation.VERTICAL
                let ship = ShipHelperObject(length: shipType.length, orientation: randomOrientation)
                dummyShipList.append(ship)
            }
        }
        // Sort ships with descending length (big ships first)
        dummyShipList.sort(by: {$0.length > $1.length})
    }

    static func getGridForKi(fleetBattleGameDetails: FleetBattleGameDetails) -> Array<Array<GridHelperObject>> {
        var result = false
        while !result {
            initData(fleetBattleGameDetails: fleetBattleGameDetails)
            result = placeDummyShips()
        }

        return grid
    }

    // Helper funcion: calculate positions around one special position (for place around the ships)
    static private func getAllPositionsAroundPosition(pos: Position) -> [Position] {
        var list = [Position]()
        let row = pos.row
        let col = pos.column
        for r in (row - 1)...(row + 1) {
            for c in (col - 1)...(col + 1) {
                if r != -1 && c != -1 {
                    list.append(Position(row: r, column: c))
                }
            }
        }

        return list
    }


    // Calculate all positions of and around ship (this positions are not available for other ships anymore)
    static private func getAllOfPositionsOfAndAroundShip(startPosition: Position, ship: ShipHelperObject) -> [Position] {
        var list = [startPosition]
        switch ship.orientation {
            case Orientation.HORIZONTAL:
                for i in startPosition.column..<startPosition.column + ship.length {
                    list += getAllPositionsAroundPosition(pos: Position(row: startPosition.row, column: i))
                }

            case Orientation.VERTICAL:
                for i in startPosition.row..<startPosition.row + ship.length {
                    list += getAllPositionsAroundPosition(pos: Position(row: i, column: startPosition.column))
                }
        }
        // Remove duplicates
        return Array(Set(list))
    }


    // Helper funcion for init: Create list with all positions of the grid (row based)
    // Multiple rows -> each row can have multiple list parts with free positions
    // Horizontal: based on rows; Vertical: based on columns
    static private func setHelperListOfPositions(orientation: Orientation) -> [[[Position]]] {
        let firstListIndex = orientation == Orientation.HORIZONTAL ? gridHeight : gridWidth
        let secondListIndex = orientation == Orientation.HORIZONTAL ? gridWidth : gridHeight
        var completeList = [[[Position]]]()
        for r in 0..<firstListIndex {
            var list = [[Position]]()
            var rowList = [Position]()
            for c in 0..<secondListIndex {
                if orientation == Orientation.HORIZONTAL {
                    rowList.append(Position(row: r, column: c))
                } else {
                    rowList.append(Position(row: c, column: r))
                }
            }

            list.append(rowList)
            completeList.append(list)
        }
        // list of all rows or columns (at first with one list of positions inside)
        return completeList
    }

    
    // Random startPosition for ships
    static private func choosePossibleStartPosition(list: [[[Position]]], ship: ShipHelperObject) -> Position? {
        // Random number for placing ship at the start or end of grid
        let randomSearchAtStartOrEnd = TPRandom.int(from: 0, to: 2)
        // All possible row indices
        var indexList = Array(0..<list.count)
        // Sort list for priorities
        indexList = randomSearchAtStartOrEnd == 0 ? indexList : indexList.reversed()
        var possiblePositionsOfElement = [Position]()
        for i in indexList {
            // Iterate over sublists of row
            for rowParts in list[i] {
                // One sublist of the row with free positions (must be long enough for ship for placing)
                if rowParts.count >= ship.length {
                    possiblePositionsOfElement = rowParts
                    // Possible startpositions in sublist of row
                    let possibleStartPositionCount = rowParts.count - ship.length
                    // Random startposition
                    let randomStartPosition = TPRandom.int(from: 0, to: possibleStartPositionCount + 1)
                    return possiblePositionsOfElement[randomStartPosition]
                }
            }
        }
        // No possible position found (all sublists not long enough)
        return nil
    }

    
    // Remove all reserved positions of list (split list in sublists if they lost a position)
    static private func updateListOfPositions(original: [[[Position]]], positions: [Position]) -> [[[Position]]] {
        var completeList: [[[Position]]] = original.map { $0 }  //original.toMutableList()
        // Iterate over list with positions
        for rowIndex in 0..<original.count {
            let row = completeList[rowIndex]
            // sublists of list
            for partIndex in 0..<row.count {
                // sublist
                let part = row[partIndex]
                // Check if sublist contains reserved positions
                
                let foundElements = Array(Set(part).intersection(Set(positions)))

                // Get indices of reserved positions
                let indexOfValues: [Int] = foundElements.map {el in part.firstIndex(of: el)!}
                // Reserved positions found in sublist
                if !indexOfValues.isEmpty {
                    // split list
                    var first = part[0..<indexOfValues[0]]
                    var second = part[indexOfValues[0]..<part.count]

                    // Remove all reserved positions
                    first = first.filter {el in !foundElements.contains(el)}
                    second = second.filter {el in !foundElements.contains(el)}
                    // Overwrite list with new sublists
                    (completeList[rowIndex]).remove(at: partIndex)
                    (completeList[rowIndex]).insert(Array(first), at: partIndex)
                    (completeList[rowIndex]).insert(Array(second), at: partIndex + 1)

                }
            }
        }

        return completeList
    }

    
    // Place all ships of the gameDetails on the grid
    static private func placeDummyShips() -> Bool {
        // Helper lists for all rows and columns (with sublists of positions)
        var listOfRows: [[[Position]]] = setHelperListOfPositions(orientation: Orientation.HORIZONTAL)
        var listOfCols: [[[Position]]] = setHelperListOfPositions(orientation: Orientation.VERTICAL)

        // Set ships
        for ship in dummyShipList {
            // Place a ship in row (horizontal) or in column (vertical)
            let relevantList = ship.orientation == Orientation.HORIZONTAL ? listOfRows : listOfCols
            // Calculate possible start position for ship
            if let startPosition = choosePossibleStartPosition(list: relevantList, ship: ship) {
                // Set values of position to true (= ship)
                setShipInGrid(ship: ship, startPosition: startPosition)
                // Remove reserved positions for space between ships
                let alreadyUsedPositions: [Position] = getAllOfPositionsOfAndAroundShip(startPosition: startPosition, ship: ship)
                listOfRows = updateListOfPositions(original: listOfRows, positions: alreadyUsedPositions)
                listOfCols = updateListOfPositions(original: listOfCols, positions: alreadyUsedPositions)
            } else {
                // No position found -> break and try again
                return false
            }
        }
        // All ships are places
        return true
    }


    // Set ship in Grid (set value to true)
    static private func setShipInGrid(ship: ShipHelperObject, startPosition: Position) {
        switch ship.orientation {
            case Orientation.HORIZONTAL:
                let fixRow = startPosition.row
                for i in 0..<ship.length {
                    grid[fixRow][startPosition.column + i].isShipSet = true
                }

            case Orientation.VERTICAL:
                let fixCol = startPosition.column
                for i in 0..<ship.length {
                    grid[startPosition.row + i][fixCol].isShipSet = true
                }
        }
    }
}
