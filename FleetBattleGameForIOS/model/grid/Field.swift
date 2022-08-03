//
//  Field.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation

protocol Field {
    var position: Position { get set }
    var isVisible: Bool { get set }
}
