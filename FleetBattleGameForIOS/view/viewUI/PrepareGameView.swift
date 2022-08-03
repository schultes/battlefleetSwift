//
//  PrepareGameView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import SwiftUI

struct PrepareGameView: View {
    
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isGridValidAndConfirmed = false
    var game: FleetBattleGame
    @StateObject var viewController: PrepareGameViewController = PrepareGameViewController()
    @State var backToMenuClicked = false
    
    var body: some View {
        if viewController.updateFailed {
            GameResultView(game: viewController.game!)
        } else {
            ZStack {
                Image("background_game")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                GeometryReader { gr in
                    ScrollView {
                        VStack(alignment: .center) {
                            Spacer()
                            Spacer(minLength: 20)
                            VStack(alignment: .center, spacing: 0) {
                                ForEach(0..<self.viewController.height, id: \.self) { row in
                                    HStack(alignment: .center, spacing: 0) {
                                        ForEach(0..<self.viewController.width, id: \.self) { column in
                                            Group {
                                                if self.viewController.cells.count > 0 && self.viewController.cells[row * self.game.gridWidth + column].isShipSet {
                                                    Rectangle().fill(Color.white.opacity(0.8)).border(Color.black, width: 1)
                                                        .frame(width: gr.size.width*0.9/CGFloat((self.viewController.width)), height: gr.size.width*0.9/CGFloat(self.viewController.width))
                                                } else if self.viewController.cells.count > 0 && !self.viewController.cells[row * self.game.gridWidth + column].isShipSet {
                                                    Rectangle().fill(Color(UIColor(hex: ColorValue.primary_normal)).opacity(0.8)).border(Color.black, width: 1)
                                                        .frame(width: gr.size.width*0.9/CGFloat((self.viewController.width)), height: gr.size.width*0.9/CGFloat(self.viewController.width))
                                                }
                                            } .onTapGesture { self.viewController.gridPositionClicked(row: row, column: column) }
                                        }
                                    }
                                }
                            }
                            // Spacer()
                            VStack(alignment: .center, spacing: 10) {
                                VStack(alignment: .center, spacing: 10) {
                                    Text("Flotte").padding(.top, 10).foregroundColor(Color(UIColor(hex: ColorValue.primary_dark)))
                                    
                                    //Text(self.viewController.fleetDescription).padding(.top, 10)
                                    if self.viewController.gameDetails != nil {
                                        VStack(alignment: .leading) {
                                            ForEach(self.viewController.gameDetails!.shipDetailList, id: \.self.length) { element in
                                                let fieldName = element.length != 1 ? "Felder" : "Feld"
                                                if let value = self.viewController.currentShipMap[element.length] {
                                                    if value == element.numberOfThisType {
                                                        Text("\(element.numberOfThisType)x \(element.name) (\(element.length) \(fieldName))")
                                                            .foregroundColor(Color(UIColor(hex: ColorValue.green)))
                                                    } else if value > element.numberOfThisType {
                                                        Text("\(element.numberOfThisType)x \(element.name) (\(element.length) \(fieldName))")
                                                            .foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal)))
                                                    } else {
                                                        Text("\(element.numberOfThisType)x \(element.name) (\(element.length) \(fieldName))")
                                                            .foregroundColor(Color(UIColor(hex: ColorValue.primary_dark)))
                                                    }
                                                } else {
                                                    Text("\(element.numberOfThisType)x \(element.name) (\(element.length) \(fieldName))")
                                                        .foregroundColor(Color(UIColor(hex: ColorValue.primary_dark)))
                                                }
                                            }
                                        }
                                        .background(Color.white.opacity(0.5)).fixedSize(horizontal: false, vertical: true).frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                    }
                                }.font(.system(size: 15, weight: .bold))
                                Spacer()
                                VStack {
                                    if self.viewController.showError {
                                        Text("\(self.viewController.errorMessage)").fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.center)
                                    } else {
                                        Text("")
                                    }
                                }.frame(minHeight: 20, maxHeight: 30).font(.system(size: 13, weight: .bold)).foregroundColor(Color(UIColor(hex: ColorValue.secondary_dark)))
                                Spacer()
                                NavigationLink(destination: LazyView {GameView(game: self.viewController.game!)}, isActive: (self.$viewController.isGridValidAndConfirmed)) {
                                    Button {
                                        self.viewController.evaluateFleetBattleGameGrid()
                                    } label: { Text("BESTÄTIGEN") }
                                    .frame(minWidth: 0, maxWidth: 120, minHeight: 30, maxHeight: 30)
                                    .foregroundColor(.white).font(.system(size: 15, weight: .bold))
                                    .background(Color(UIColor(hex: self.viewController.isButtonSelectable == true ? ColorValue.secondary_normal : ColorValue.grey))).cornerRadius(8)  
                                }.isDetailLink(false)
                                Spacer()
                            }
                            
                        }.frame(minWidth: gr.size.width, maxWidth: gr.size.width, minHeight:gr.size.height, maxHeight:gr.size.height)
                    }
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Spielplan vorbereiten").font(.headline).foregroundColor(.white)
                        Text("Platziere deine Flotte").font(.subheadline).foregroundColor(Color(UIColor(hex: ColorValue.subtitle)))
                    }
                }
            }
            .navigationBarItems(
                leading:
                    Button(action:  {
                        self.viewController.generateRandomGrid()
                    }) {
                        Image("prepare_game_random")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                    }
                ,
                trailing: Button(action: {
                    self.backToMenuClicked = true
                }) {
                    getCloseButtonImage()
                })
            
            
            .onAppear() {
                self.viewController.initViewController(game: self.game)
            }
            .alert(isPresented: $backToMenuClicked) {
                Alert(
                    title: Text("Willst du die Platzierung abbrechen? \(calculateAlertText())"),
                    message: nil,
                    primaryButton: .destructive(Text("Ja")) {
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text("Nein"))
                )
            }
        }
    }
    
    func calculateAlertText() -> String {
        if game.mode == GameMode.SINGLEPLAYER {
            return "Dein Spielstand geht dabei verloren."
        }
        return "Das Spiel selbst bleibt erhalten."
    }
}


struct PrepareGameView_Previews: PreviewProvider {
    static var previews: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        let date = dateFormatter.string(from: Date())
        let game = FleetBattleGame(fleetBattleGameDetails: GameService.getFleetBattleGameById(id: "1"), createdAt: date, mode: GameMode.MULTIPLAYER, playerName1: AuthenticationService.getUsername()!, difficultyLevel: nil)
        return PrepareGameView(game: game)
    }
}
