//
//  StartView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 20.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import SwiftUI

struct StartView: View {
    
    var body: some View {
        Group {
            NavigationView {
                if AuthenticationService.getUsername() != nil {
                    MenuView()
                } else {
                    LoginView()
                }
            }
            .navigationBarColor(backgroundColor: UIColor(hex: ColorValue.primary_normal), titleColor: .white)
        }
    }
}
    
struct LazyView<Content: View>: View {
    var content: () -> Content
    var body: some View {
        self.content()
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
