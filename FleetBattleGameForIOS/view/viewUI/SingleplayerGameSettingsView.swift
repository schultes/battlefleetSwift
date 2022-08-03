//
//  GameSettingView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import SwiftUI

struct SingleplayerGameSettingsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewController = SingleplayerGameSettingsViewController()
    @State var expandDifficultyMenu = false
    
    
    var body: some View {
        if self.viewController.isCreatingSucceeded == false {
            ZStack {
                Image("background_menu")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                GeometryReader { gr in
                    VStack(alignment: .center, spacing: 0) {
                        
                        Text("Schwierigkeitsgrad").foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal))).font(.system(size: 20, weight: .bold)).padding(.top, 20).padding(.bottom, 15)
                        drawDifficultySelection().frame(minWidth: 0, maxWidth: gr.size.width, minHeight: 0, maxHeight: gr.size.height*0.1)
                        
                        Text("Variante").foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal))).font(.system(size: 20, weight: .bold)).padding(.top, 20).padding(.bottom, 20)
                        drawGameDetailsSelection().frame(minWidth: 0, maxWidth: gr.size.width*0.7, minHeight: 0, maxHeight: gr.size.height*0.1)
                        drawGameDetailsOfSelection()
                        Spacer()
                        
                        Button {
                            self.viewController.createNewGame()
                        } label: {
                            Text("BESTÄTIGEN")
                                .padding(.vertical, 30)
                                .frame(minWidth: 0, maxWidth: 180, minHeight: 33, maxHeight: 42)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.white)
                                .background(Color(UIColor(hex: ColorValue.primary_normal)))
                                .cornerRadius(10)
                        }.padding(.bottom, 20)
                        Spacer()
                    }.frame(width: gr.size.width, height: gr.size.height)
                    
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
        } else if self.viewController.isCreatingSucceeded == true {
            PrepareGameView(game: self.viewController.newGameWithId!)
        }
    }
    
    func drawGameDetailsOfSelection() -> some View {
        let details = self.viewController.chosenGameDetails
        return VStack(alignment: .leading) {
            Text("Maße: \(details.gridWidth)x\(details.gridHeight)")
            Text("")
            ForEach(details.shipDetailList, id: \.self.length) { ship in
                Text("\(ship.numberOfThisType)x \(ship.name) (\(ship.length) \(ship.length == 1 ? "Feld" : "Felder"))")
            }
        }
        .background(Color.white.opacity(0.5))
        .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
        .font(.system(size: 15, weight: .bold))
    }
    
    func drawGameDetailsSelection() -> some View {
        return GeometryReader { gr in
            Menu {
                ForEach(GameService.listOfAllGameModes, id: \.self.id) { detail in
                    Button(detail.name) {
                        self.viewController.chosenGameDetails = detail
                    }
                }
            } label: {
                VStack(alignment: .center, spacing: 5) {
                    HStack(alignment: .center, spacing: 5) {
                        Text(self.viewController.chosenGameDetails.name)
                            .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                            .font(.system(size: 15, weight: .bold))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(Font.system(size: 20, weight: .bold))
                            
                    }.frame(width: gr.size.width*0.8, alignment: .center)
                    .padding(.horizontal)
                    Rectangle()
                        .fill(Color(UIColor(hex: ColorValue.primary_dark)))
                        .frame(height: 2)
                }
            }
        }
    }

    
    func drawDifficultySelection() -> some View {
        return GeometryReader { gr in
            HStack(alignment: .center, spacing: 0) {
                Button(action:  {
                    self.viewController.chosenDifficulty = DifficultyLevel.EASY
                }) {
                    if self.viewController.chosenDifficulty == DifficultyLevel.EASY {
                        Text("LEICHT")
                            .frame(minWidth: 0, maxWidth: gr.size.width/4, minHeight: 30, maxHeight: 30)
                            .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                            .font(.system(size: 12, weight: .bold))
                            .border(Color(UIColor(hex: ColorValue.primary_normal)), width: 2)
                    } else {
                        Text("LEICHT")
                            .frame(minWidth: 0, maxWidth: gr.size.width/4, minHeight: 30, maxHeight: 30)
                            .foregroundColor(Color(UIColor(hex: ColorValue.darkGray)))
                            .font(.system(size: 12, weight: .bold))
                            .border(Color.white, width: 1)
                    }
                }
                Button(action:  {
                    self.viewController.chosenDifficulty = DifficultyLevel.MEDIUM
                }) {
                    if self.viewController.chosenDifficulty == DifficultyLevel.MEDIUM {
                        Text("MITTEL")
                            .frame(minWidth: 0, maxWidth: gr.size.width/4, minHeight: 30, maxHeight: 30)
                            .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                            .font(.system(size: 12, weight: .bold))
                            .border(Color(UIColor(hex: ColorValue.primary_normal)), width: 2)
                    } else {
                        Text("MITTEL")
                            .frame(minWidth: 0, maxWidth: gr.size.width/4, minHeight: 30, maxHeight: 30)
                            .foregroundColor(Color(UIColor(hex: ColorValue.darkGray)))
                            .font(.system(size: 12, weight: .bold))
                            .border(Color.white, width: 1)
                    }
                }
                Button(action:  {
                    self.viewController.chosenDifficulty = DifficultyLevel.HARD
                }) {
                    if self.viewController.chosenDifficulty == DifficultyLevel.HARD {
                        Text("SCHWER")
                            .frame(minWidth: 0, maxWidth: gr.size.width/4, minHeight: 30, maxHeight: 30)
                            .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                            .font(.system(size: 12, weight: .bold))
                            .border(Color(UIColor(hex: ColorValue.primary_normal)), width: 2)
                    } else {
                        Text("SCHWER")
                            .frame(minWidth: 0, maxWidth: gr.size.width/4, minHeight: 30, maxHeight: 30)
                            .foregroundColor(Color(UIColor(hex: ColorValue.darkGray)))
                            .font(.system(size: 12, weight: .bold))
                            .border(Color.white, width: 1)
                    }
                }
            }.frame(minWidth: 0, maxWidth: gr.size.width)
        }
        
        
    }
}

struct GameSettingView_Previews: PreviewProvider {
    static var previews: some View {
        SingleplayerGameSettingsView()
    }
}
