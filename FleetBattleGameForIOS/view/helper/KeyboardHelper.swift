//
//  KeyboardHelper.swift
//  FleetBattleGameForIOS
//
//  Created by FMA2 on 13.01.22.
//  Copyright © 2022 FMA2. All rights reserved.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
