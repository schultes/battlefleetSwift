//
//  FleetBattleGameDetails.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

struct FleetBattleGameDetails: Serializable {
    let id: String
    let name: String
    let gridWidth: Int
    let gridHeight: Int
    let shipDetailList: [ShipDetails]
}
