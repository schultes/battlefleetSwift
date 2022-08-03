//
//  GameObservableObject.swift
//  FleetBattleGame
//
//  Created by FMA2 on 29.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation
import SwiftUI

class GameObservableObject: ObservableObject {
    @Published var game: FleetBattleGame
    
    init(game: FleetBattleGame) {
        self.game = game
    }
}


