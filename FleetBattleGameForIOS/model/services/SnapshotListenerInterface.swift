//
//  SnapshotListenerInterface.swift
//  FleetBattleGame
//
//  Created by FMA2 on 07.01.22.
//  Copyright © 2022 FMA2. All rights reserved.
//


protocol SnapshotListenerInterface {
    func startListening(id: String, callback: @escaping (FleetBattleGame?, String?) -> ())
    func removeListener()
}
