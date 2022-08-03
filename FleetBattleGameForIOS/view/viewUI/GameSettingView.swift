//
//  GameSettingView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import SwiftUI

struct GameSettingsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewController = GameSettingsViewController()
    
    
    var body: some View {
        VStack {
            Text("Schwierigkeitsgrad")
            HStack {
                Button(action:  {
                    print("Hallo")
                }) {
                    
                    Text("LEICHT")
                        .frame(minWidth: 0, maxWidth: 180, minHeight: 40, maxHeight: 40)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                        //.background(Color(UIColor(hex: ColorValue.primary_normal)))
                        .cornerRadius(8)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: getBackButton(presentationMode: self.presentationMode))
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Spiel erstellen").font(.headline).foregroundColor(.white)
                    Text("Einstellungen").font(.subheadline).foregroundColor(Color(UIColor(hex: ColorValue.subtitle)))
                }
            }
        }
    }
}

struct GameSettingView_Previews: PreviewProvider {
    static var previews: some View {
        GameSettingsView()
    }
}
