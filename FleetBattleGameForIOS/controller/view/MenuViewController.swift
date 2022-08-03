//
//  MenuViewController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation

class MenuViewController: ObservableObject {
    @Published var isSignedIn = AuthenticationService.getUsername() != nil
    
    func signOut() {
        AuthenticationService.signOut()
        isSignedIn = false
    }
}
