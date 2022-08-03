//
//  OpenGamesView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import SwiftUI

struct OpenGamesView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var chosenGame: FleetBattleGame?
    @StateObject var viewController = OpenGamesViewController()
    
    var body: some View {
        // Enter open game
        if self.viewController.newGameWithId != nil && self.viewController.isUpdateSucceeded {
            PrepareGameView(game: self.viewController.newGameWithId!)
        }
        // Enter deleted game
        if self.viewController.newGameWithId != nil && self.viewController.updateFailed {
            GameResultView(game: self.viewController.newGameWithId!)
        }
        // Enter running game (check if we need to set our grid first)
        if chosenGame != nil && GameService.isOwnGridSet(game: chosenGame!) {
            GameView(game: chosenGame!)
        } else if chosenGame != nil && !GameService.isOwnGridSet(game: chosenGame!) {
            PrepareGameView(game: chosenGame!)
        } else {
            
            ZStack {
                Image("background_menu")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                GeometryReader { gr in
                    ScrollView {
                        
                        VStack(alignment: .center) {
                            
                            Group {
                                if self.viewController.listOfRunningGames.count == 0 {
                                    if self.viewController.listOfOtherOpenGames.count == 0 {
                                        if self.viewController.listOfOwnOpenGames.count == 0 {
                                        Text("Es sind noch keine Spiele vorhanden. Erstelle ein neues!")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal)))
                                            .padding(.top, 15)
                                            .multilineTextAlignment(.center)
                                            .frame(minWidth: 0, maxWidth: gr.size.width*0.8)
                                        }
                                    }
                                }
                            }
                            
                            Group {
                                if self.viewController.listOfRunningGames.count > 0 {
                                    Group {
                                        Text("Deine laufenden Spiele").font(.system(size: 15, weight: .bold)).foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal))).padding(.top, 15)
                                        ForEach(self.viewController.listOfRunningGames, id: \.self.documentId!) { game_1 in
                                            GameListItemView(
                                                game: game_1, listType: 1,
                                                formattedDate: DateTimeHelper.getFormattedDateAsString(dateString: game_1.createdAt),
                                                gameDetailsName: GameService.getFleetBattleGameById(id: game_1.gameDetailsId).name
                                            )
                                                .frame(width: gr.size.width*0.9, height: 48)
                                                .onTapGesture { self.chosenGame = game_1 }
                                        }
                                    }
                                }
                                
                                if self.viewController.listOfOwnOpenGames.count > 0 {
                                    Group {
                                        Text("Deine erstellten Anfragen").font(.system(size: 15, weight: .bold)).foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal))).padding(.top, 15)
                                        ForEach(self.viewController.listOfOwnOpenGames, id: \.self.documentId!) { game_2 in
                                            GameListItemView(game: game_2, listType: 2, formattedDate: DateTimeHelper.getFormattedDateAsString(dateString: game_2.createdAt), gameDetailsName: GameService.getFleetBattleGameById(id: game_2.gameDetailsId).name)
                                                .frame(width: gr.size.width*0.9, height: 48)
                                                .onTapGesture { self.chosenGame = game_2 }
                                        }
                                    }
                                }
                                if self.viewController.listOfOtherOpenGames.count > 0 {
                                    Group {
                                        Text("Offene Spiele").font(.system(size: 15, weight: .bold)).foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal))).padding(.top, 15)
                                        ForEach(self.viewController.listOfOtherOpenGames, id: \.self.documentId!) { game_3 in
                                            GameListItemView(game: game_3, listType: 3, formattedDate: DateTimeHelper.getFormattedDateAsString(dateString: game_3.createdAt), gameDetailsName: GameService.getFleetBattleGameById(id: game_3.gameDetailsId).name
                                                             
                                            )
                                                .frame(width: gr.size.width*0.9, height: 48)
                                                .onTapGesture {
                                                    self.viewController.setPlayer2(game: game_3)
                                                    self.chosenGame = game_3
                                                }
                                        }
                                    }
                                }
                                
                                
                                
                            }
                        }.frame(minWidth: 0, maxWidth: gr.size.width).padding(.bottom, 10)
                    }.frame(minHeight: 0, maxHeight: gr.size.height)
                }
            }
            
            .navigationBarTitle(GameMode.MULTIPLAYER.rawValue, displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: getBackButton(presentationMode: self.presentationMode), trailing: getCreateGameButton())           
        }
    }
    
    private func getCreateGameButton() -> some View {
        return NavigationLink(destination: MultiplayerGameSettingsView()) {
            HStack(spacing: 0) {
                Image("navigation_add")
                    .resizable().renderingMode(.template)
                    .frame(width: 25, height: 25).foregroundColor(Color.white)
            }
        }
    }
    
}



struct OpenGamesView_Previews: PreviewProvider {
    static var previews: some View {
        OpenGamesView()
    }
}
