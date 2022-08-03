//
//  FleetBattleKI.swift
//  FleetBattleGame
//
//  Created by FMA2 on 07.01.22.
//  Copyright © 2022 FMA2. All rights reserved.
//

class FleetBattleKI {
    private let difficultyLevel: DifficultyLevel
    private var fleetBattleGrid: FleetBattleGrid
    private var availablePositions: [[Bool]]
    private var prioritizedPositions: [[Bool]]
    private var followupPositions: [Position]
    
    init(difficultyLevel: DifficultyLevel, fleetBattleGrid: FleetBattleGrid) {
        self.difficultyLevel = difficultyLevel
        self.fleetBattleGrid = fleetBattleGrid
        availablePositions = [[Bool]]()
        prioritizedPositions = [[Bool]]()
        followupPositions = [Position]()
        
        for _ in 0..<fleetBattleGrid.width {
            var tempListForAvailablePositions = [Bool]()
            var tempListForPrioritizedPositions = [Bool]()
            for _ in 0..<fleetBattleGrid.height {
                tempListForAvailablePositions.append(true)
                tempListForPrioritizedPositions.append(false)
            }
            availablePositions.append(tempListForAvailablePositions)
            prioritizedPositions.append(tempListForPrioritizedPositions)
        }
        
        if difficultyLevel != DifficultyLevel.EASY {
            generatePrioritizedPositions()
        }
        
    }
    
    func getNextTurn(wasLastMoveByKI: Bool) -> Position {
        let resultPos: Position
        let prioPos = getPosArrayFromGrid(list: prioritizedPositions)
        if followupPositions.count > 0 {
            resultPos = getRandomPositionWithErrorProbability(positions: followupPositions, wasLastMoveByKI: wasLastMoveByKI)
        } else if prioPos.count > 0 {
            resultPos = getRandomPositionWithErrorProbability(positions: prioPos, wasLastMoveByKI: wasLastMoveByKI)
        } else {
            let availablePos = getPosArrayFromGrid(list: availablePositions)
            resultPos = getRandomPositionWithErrorProbability(positions: availablePos, wasLastMoveByKI: wasLastMoveByKI)
        }
        return resultPos
    }
    
    // Get random position of list with possible error probability if ki already hit a ship in the last move
    private func getRandomPositionWithErrorProbability(positions: [Position], wasLastMoveByKI: Bool) -> Position {
        let shouldKiHitWrongField = calculateErrorProbability()
        if wasLastMoveByKI && shouldKiHitWrongField {
            let shipList = positions.filter {position in (fleetBattleGrid.fields[position.row][position.column] as! FleetBattleField).ship != nil}
            let waterList = positions.filter {position in (fleetBattleGrid.fields[position.row][position.column] as! FleetBattleField).ship == nil}
            return !waterList.isEmpty ? waterList[TPRandom.int(from: 0, to: waterList.count)] : shipList[TPRandom.int(from: 0, to: shipList.count)]
        }
        return positions[TPRandom.int(from: 0, to: positions.count)]
    }
    
    // Calculate if ki should hit wrong field (random)
    private func calculateErrorProbability() -> Bool {
        let randomValue = TPRandom.int(from: 0, to: 100)
        if randomValue < 20 {
            return false // 20% correct
        }
        return true // 80% wrong
    }
    
    func updateGrid(fleetBattleGrid: FleetBattleGrid) {
        let gridWidth = fleetBattleGrid.width
        let gridHeight = fleetBattleGrid.height
        for y in 0..<fleetBattleGrid.height { //update available positions
            for x in 0..<fleetBattleGrid.width {
                if fleetBattleGrid.fields[y][x].isVisible {
                    let field = fleetBattleGrid.fields[y][x] as! FleetBattleField
                    availablePositions[x][y] = false
                    if let it = field.ship {
                        if it.submerged {
                            for row in (y - 1)...(y + 1) {
                                for col in (x - 1)...(x + 1) {
                                    if row >= 0 && col >= 0 && row < gridHeight && col < gridWidth {
                                        availablePositions[col][row] = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        followupPositions.removeAll()
        for ship in fleetBattleGrid.ships {
            if !ship.submerged {
                var hits = [Position]()
                for position in ship.getAllPositionsOfShip() {
                    let field = fleetBattleGrid.getField(pos: position)
                    if field.isVisible {
                        hits.append(position)
                    }
                }
                
                if hits.count == 1 {
                    let x = hits[0].column
                    let y = hits[0].row
                    if x > 0 && availablePositions[x - 1][y] {
                        followupPositions.append(Position(row: y, column: x - 1))
                    }
                    
                    if x < gridWidth - 1 && availablePositions[x + 1][y] {
                        followupPositions.append(Position(row: y, column: x + 1))
                    }
                    
                    if y > 0 && availablePositions[x][y - 1] {
                        followupPositions.append(Position(row: y - 1, column: x))
                    }
                    
                    if y < gridHeight - 1 && availablePositions[x][y + 1] {
                        followupPositions.append(Position(row: y + 1, column: x))
                    }
                } else if hits.count > 1 {
                    if ship.orientation == Orientation.HORIZONTAL {
                        if hits[0].column > 0 && availablePositions[hits[0].column - 1][hits[0].row] {
                            followupPositions.append(Position(row: hits[0].row, column: hits[0].column - 1))
                        }
                        
                        if hits[hits.count - 1].column < gridWidth - 1 && availablePositions[hits[hits.count - 1].column + 1][hits[hits.count - 1].row] {
                            followupPositions.append(Position(row: hits[hits.count - 1].row, column: hits[hits.count - 1].column + 1))
                        }
                    } else {
                        if hits[0].row > 0 && availablePositions[hits[0].column][hits[0].row - 1] {
                            followupPositions.append(Position(row: hits[0].row - 1, column: hits[0].column))
                        }
                        
                        if hits[hits.count - 1].row < gridHeight - 1 && availablePositions[hits[hits.count - 1].column][hits[hits.count - 1].row + 1] {
                            followupPositions.append(Position(row: hits[hits.count - 1].row + 1, column: hits[hits.count - 1].column))
                        }
                    }
                }
                
                if hits.count != 0 {
                    break
                }
            }
        }
        
        generatePrioritizedPositions()
    }
    
    private func generatePrioritizedPositions() {
        let gridHeight = fleetBattleGrid.height
        let gridWidth = fleetBattleGrid.width
        switch difficultyLevel {
        case DifficultyLevel.MEDIUM:
            let offsetCountX = gridWidth % 2 == 1 ? 1 : 0
            let borderOffsetX: Int = (gridWidth / 4) + offsetCountX
            
            let offsetCountY = gridHeight % 2 == 1 ? 1 : 0
            let borderOffsetY: Int = (gridHeight / 4) + offsetCountY
            
            for x in borderOffsetX..<(gridWidth - borderOffsetX) {
                for y in borderOffsetY..<(gridHeight - borderOffsetY) {
                    prioritizedPositions[x][y] = true
                }
            }
            
        case DifficultyLevel.HARD:
            let ships = fleetBattleGrid.ships
            var maxLength = 0
            for ship in ships {
                if !ship.submerged && ship.length > maxLength {
                    maxLength = ship.length
                }
            }
            
            generateHardGrid(maxLength: maxLength)
        default: return
        }
        
        for y in 0..<fleetBattleGrid.height {
            for x in 0..<fleetBattleGrid.width {
                if !availablePositions[x][y] {
                    prioritizedPositions[x][y] = false
                }
            }
        }
    }
    
    private func generateHardGrid(maxLength: Int) {
        for y in 0..<fleetBattleGrid.height {
            for x in 0..<fleetBattleGrid.width {
                prioritizedPositions[x][y] = false
            }
            
            for x in stride(from: (0 - y), to: fleetBattleGrid.width, by: maxLength) {
                if x >= 0 {
                    prioritizedPositions[x][y] = true
                }
            }
        }
    }
    
    private func getPosArrayFromGrid(list: [[Bool]]) -> [Position] {
        var resultList = [Position]()
        for y in 0..<list[0].count {
            for x in 0..<list.count {
                if list[x][y] {
                    resultList.append(Position(row: y, column: x))
                }
            }
        }
        
        return resultList
    }
}
