//
//  Game.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

protocol Game {
    var createdAt: String { get set }
    var gridHeight: Int { get set }
    var gridWidth: Int { get set }
    var mode: GameMode { get set }
    var playerName1: String { get set }
    var playerName2: String? { get set }
    var isFinished: Bool { get set }
    var winner: String? { get set }
    var usersTurn: Int { get set }
    var difficultyLevel: DifficultyLevel? { get set }
    var lastMoveBy: String? { get set }
}
