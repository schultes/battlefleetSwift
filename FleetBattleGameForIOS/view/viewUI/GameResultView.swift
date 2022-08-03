//
//  GameResultView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import SwiftUI

struct GameResultView: View {
    
    var game: FleetBattleGame
    @StateObject var viewController = GameResultViewController()
    
    var body: some View {
        ZStack {
            Image("background_menu")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            GeometryReader { gr in
                VStack {
                    Spacer()
                    Text(viewController.headline)
                        .font(.largeTitle).bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal)))
                    Spacer()
                    VStack(alignment: .center, spacing: 10) {
                                               
                        if game.mode == GameMode.SINGLEPLAYER {
                            Text(viewController.detailsStart) +
                            Text(viewController.detailsMiddle) +
                            Text(viewController.detailsEnd)
                        } else {
                            (Text(viewController.detailsStart) +
                                Text(viewController.detailsMiddle).underline() +
                            Text(viewController.detailsEnd))
                        }
                        
                        Text(viewController.singlePlayerDetails)
                            .padding(.vertical, 10)
                        
                    }.foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal)))
                    Spacer()
                    
                    Image(viewController.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: gr.size.width*0.7, height: gr.size.height*0.28)
                    
                    Spacer()
                    VStack {
                        NavigationLink(destination: MenuView()) {
                            Text("STARTSEITE")
                                .padding(.vertical, 30)
                                .frame(minWidth: 0, maxWidth: 180, minHeight: 33, maxHeight: 42)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.white)
                                .background(Color(UIColor(hex: ColorValue.primary_normal)))
                                .cornerRadius(10)
                        }.isDetailLink(false)
                        .padding(.horizontal, 50)
                    }
                    Spacer()
                }.frame(minWidth: gr.size.width, minHeight: gr.size.height)
            }
        }
        .onAppear() {
            self.viewController.setStrings(game: game)
        }
        .onDisappear() {
            if self.game.mode == GameMode.SINGLEPLAYER {
                DatabaseService.deleteOldSingleplayerGameOfUser()
            } else {
                DatabaseService.deleteFinishedMultiplayerGamesOfUser()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(Texts.appName).font(.headline).foregroundColor(.white)
                    Text("Ergebnis").font(.subheadline).foregroundColor(Color(UIColor(hex: ColorValue.subtitle)))
                }
            }
        }
    }
}

struct GameResultView_Previews: PreviewProvider {
    static var previews: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        let date = dateFormatter.string(from: Date())
        let game = FleetBattleGame(fleetBattleGameDetails: GameService.getFleetBattleGameById(id: "1"), createdAt: date, mode: GameMode.MULTIPLAYER, playerName1: AuthenticationService.getUsername()!, difficultyLevel: nil)
        
        return GameResultView(game: game)
    }
}
