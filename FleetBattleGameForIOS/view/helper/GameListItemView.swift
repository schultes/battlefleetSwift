//
//  GameListItemView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.12.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import SwiftUI

struct GameListItemView: View {
    let game: FleetBattleGame
    let listType: Int
    let formattedDate: String
    let gameDetailsName: String
    @State private var showingAlert = false
    
    var body: some View {
        
        HStack {

            Image(calculateImage(listType: listType, game: game))
                .resizable()
                .renderingMode(.template)
                .frame(width: 40, height: 40).foregroundColor(Color(UIColor(hex: ColorValue.primary_dark)))
                .padding(.horizontal, 10)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    if game.playerName2 == nil {
                        Text("Spieler: \(game.playerName1)")
                            .font(.system(size: 15, weight: .bold))
                    } else {
                        Text("\(game.playerName1) vs. \(game.playerName2!)")
                            .font(.system(size: 15, weight: .bold))
                        
                    }
                    if game.playerName1 == AuthenticationService.getUsername() || (game.playerName2 != nil && game.playerName2 == AuthenticationService.getUsername()) {
                        Spacer()
                        Button(action:  {
                            self.showingAlert = true
                        }) {
                        Image("list_game_trash_icon")
                            .resizable()
                            .frame(width: 15, height: 15)
                        }.alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Möchtest du das Spiel wirklich löschen?"),
                                message: nil,
                                primaryButton: .destructive(Text("Ja")) {
                                    DatabaseService.deleteGameById(id: game.documentId!)
                                },
                                secondaryButton: .cancel(Text("Nein"))
                            )
                        }

                    }
                }
                Text("\(formattedDate) (\(gameDetailsName))")
                    .font(.system(size: 15))
            }
            .foregroundColor(Color(UIColor(hex: ColorValue.primary_dark)))
            .padding(.vertical, 5)
            Spacer()
        }
        .background(Color.white)
        .cornerRadius(8)
        .foregroundColor(Color(UIColor(hex: ColorValue.primary_dark)))
    }
    
    private func calculateImage(listType: Int, game: FleetBattleGame) -> String {
        switch listType {
        case 2:
            return "list_game_waiting"
        case 3:
            return "list_game_searching"
        default:
            let areAllGridsSet = game.gridFromPlayer1 != nil && game.gridFromPlayer2 != nil
            let ownUserTurnNumber = game.playerName1 == AuthenticationService.getUsername() ? 1 : 2
            let imageName = (!GameService.isOwnGridSet(game: game) || (areAllGridsSet && game.usersTurn == ownUserTurnNumber)) ? "list_game_single_sword" : "list_game_running"
            return imageName
        }
    }
}
