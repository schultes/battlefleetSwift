//
//  MultiplayerGameSettingsView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 05.01.22.
//  Copyright © 2022 FMA2. All rights reserved.
//

import SwiftUI

struct MultiplayerGameSettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var secondPlayerName = ""
    @StateObject var viewController = MultiplayerGameSettingsViewController()
    @State var endEditing = false
    
    var body: some View {
        if self.viewController.isCreatingSucceeded == false {
            ZStack {
                Image("background_menu")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                GeometryReader { gr in
                    VStack(alignment: .center, spacing: 0) {
                        Text("Reservierung").foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal))).font(.system(size: 20, weight: .bold)).padding(.top, 20).padding(.bottom, 15)
                        drawSecondPlayerSelection().frame(minWidth: 0, maxWidth: gr.size.width*0.7, minHeight: gr.size.height*0.1, maxHeight: gr.size.height)
                        
                        
                        Text("Variante").foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal))).font(.system(size: 20, weight: .bold)).padding(.top, 20).padding(.bottom, 20)
                        drawGameDetailsSelection().frame(minWidth: 0, maxWidth: gr.size.width*0.5, minHeight: 0, maxHeight: gr.size.height*0.1)
                        drawGameDetailsOfSelection()
                        Spacer()
                        
                        VStack {
                            if self.viewController.isPresentingPopup {
                                Text("Kein gültiger Spielername").fixedSize(horizontal: false, vertical: true).font(.system(size: 13, weight: .bold)).foregroundColor(Color(UIColor(hex: ColorValue.secondary_dark))).padding(10).background((Color.white).opacity(0.5))
                                    .cornerRadius(8)
                            }
                        }.frame(minWidth: 0, minHeight: 50)
                        
                        Spacer()
                        Button {
                            self.viewController.createNewGame(secondPlayerName: secondPlayerName)
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
                        
                    }.frame(minWidth: gr.size.width, minHeight: gr.size.height)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
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
            
        } else if self.viewController.isCreatingSucceeded == true {
            PrepareGameView(game: self.viewController.newGameWithId!)
        }
        
    }
    
    func drawSecondPlayerSelection() -> some View {
        return GeometryReader { gr in
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Button(action:  {
                        self.viewController.isGameReserved = false
                    }) {
                        if self.viewController.isGameReserved == false {
                            Text("OFFEN")
                                .frame(minWidth: 0, maxWidth: gr.size.width/2, minHeight: 30, maxHeight: 30)
                                .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                                .font(.system(size: 12, weight: .bold))
                                .border(Color(UIColor(hex: ColorValue.primary_normal)), width: 2)
                        } else {
                            Text("OFFEN")
                                .frame(minWidth: 0, maxWidth: gr.size.width/2, minHeight: 30, maxHeight: 30)
                                .foregroundColor(Color(UIColor(hex: ColorValue.darkGray)))
                                .font(.system(size: 12, weight: .bold))
                                .border(Color.white, width: 1)
                        }
                    }
                    
                    Button(action:  {
                        self.viewController.isGameReserved = true
                    }) {
                        if self.viewController.isGameReserved == true {
                            Text("RESERVIERT")
                                .frame(minWidth: 0, maxWidth: gr.size.width/2, minHeight: 30, maxHeight: 30)
                                .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                                .font(.system(size: 12, weight: .bold))
                                .border(Color(UIColor(hex: ColorValue.primary_normal)), width: 2)
                        } else {
                            Text("RESERVIERT")
                                .frame(minWidth: 0, maxWidth: gr.size.width/2, minHeight: 30, maxHeight: 30)
                                .foregroundColor(Color(UIColor(hex: ColorValue.darkGray)))
                                .font(.system(size: 12, weight: .bold))
                                .border(Color.white, width: 1)
                        }
                    }
                }.frame(minWidth: 0, maxWidth: gr.size.width)
                if viewController.isGameReserved {
                    TextField("", text: $secondPlayerName, onEditingChanged: { editChanged in
                        if editChanged {
                            endEditing = false
                            if !secondPlayerName.isEmpty {
                                viewController.filteredNames = viewController.allPlayerNames.filter { name in
                                    name.uppercased().starts(with: secondPlayerName.uppercased())
                                }
                            } else {
                                viewController.filteredNames.removeAll()
                            }
                        } else {
                            viewController.filteredNames.removeAll()
                        }
                    })
                        .frame(minWidth: 200, maxWidth: 300)
                        .padding(8)
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                        .textContentType(.name)
                        .keyboardType(.default)
                        .compositingGroup()
                        .shadow(radius: 5)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                        .textFieldStyle(BottomLineTextFieldStyle())
                        .placeholder(when: secondPlayerName.isEmpty) {
                            Text("Mitspieler Name").foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                                .padding(8).font(.system(size: 15))
                                .padding(.bottom, 10)
                        }
                        .onChange(of: secondPlayerName, perform: { secondPlayerName in
                            if !secondPlayerName.isEmpty {
                                viewController.filteredNames = viewController.allPlayerNames.filter { name in
                                    name.uppercased().starts(with: secondPlayerName.uppercased())
                                }
                            } else {
                                viewController.filteredNames.removeAll()
                            }
                        })
                    if !viewController.filteredNames.isEmpty && endEditing == false {
                        List(viewController.filteredNames, id: \.self) { name in
                            ZStack {
                                Text(name).font(.system(size: 15))
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 10, maxHeight: .infinity, alignment: .leading)
                            .onTapGesture {
                                secondPlayerName = name
                                
                                endEditing = true
                                viewController.filteredNames.removeAll()
                                UIApplication.shared.endEditing()
                                
                            }
                        }.foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal)))
                    }
                    
                }
            }
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
}

struct MultiplayerGameSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplayerGameSettingsView()
    }
}
