//
//  BackButton.swift
//  FleetBattleGame
//
//  Created by FMA2 on 22.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation
import SwiftUI

func getBackButton(presentationMode: Binding<PresentationMode>) -> some View {
    return Button(action: {
        presentationMode.wrappedValue.dismiss()
    }) {
        HStack(spacing: 0) {
            Image(systemName: "chevron.left")
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
        }
    }
}

func getCloseButton() -> some View {
    return NavigationLink(destination: MenuView()) {
        getCloseButtonImage()
    }
}

func getCloseButtonImage() -> some View {
    return Image("navigation_cancel")
        .resizable()
        .renderingMode(.template)
        .foregroundColor(.white)
        .frame(width: 30, height: 30)
}
