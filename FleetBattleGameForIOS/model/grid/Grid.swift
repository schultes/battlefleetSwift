//
//  Grid.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//


protocol Grid {
    var width: Int { get set }
    var height: Int { get set }
    var fields: [[Field]] { get set }
    
    func getField(pos: Position) -> Field
}
