//
//  GameView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import SwiftUI

struct GameView: View {
    
    var game: FleetBattleGame
    
    @StateObject var viewController = GameViewController()
    @State var backToMenuClickedConfirmed = false
    @State var backToMenuClicked = false
    
    var body: some View {
        if backToMenuClickedConfirmed {
            MenuView()
        } else if viewController.showGameResultView {
            GameResultView(game: self.viewController.gameForResult!)
        } else {
            ZStack {
                Image("background_game")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                GeometryReader { gr in
                    
                    ScrollView {
                        VStack {
                            Group {
                                if self.viewController.game != nil {
                                    drawStatusText().frame(minWidth: 0, maxWidth: gr.size.width*0.9, minHeight: 0, maxHeight: gr.size.height*0.1)
                                    drawGrid().frame(minWidth: 0, maxWidth: gr.size.width, minHeight: 0, maxHeight: gr.size.width)
                                    drawShipCount().frame(minWidth: 0, maxWidth: gr.size.width*0.9, minHeight: 0, maxHeight: gr.size.height*0.2)
                                } else {
                                    Text("")
                                }
                            }
                        }.frame(width: gr.size.width, height: gr.size.height)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("\(game.playerName1) VS. \(game.playerName2 ?? "???")").font(.headline).foregroundColor(.white)
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: {
                self.viewController.snapshotListener.removeListener()
                self.backToMenuClicked = true
            }) {
                getCloseButtonImage()
            })
            .onAppear() {
                self.viewController.initViewController(game: self.game)
            }
            .alert(isPresented: $backToMenuClicked) {
                Alert(
                    title: Text("Willst du das Spiel wirklich verlassen? \(calculateAlertText())"),
                    message: nil,
                    primaryButton: .destructive(Text("Ja")) {
                        self.backToMenuClickedConfirmed = true
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
    
    func drawShipCount() -> some View {
        return
            GeometryReader { gr in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Flotte:")
                        ForEach((0...viewController.gameDetails.shipDetailList.count-1), id: \.self) { index in
                            Text("\(viewController.shipDetailList[index][0] as! String)")
                        }
                    }.frame(minWidth: 0, maxWidth: gr.size.width*0.4).background(Color.white.opacity(0.5))
                    
                    VStack {
                        Text("\(viewController.game!.playerName1)").scaledToFit()
                        ForEach((0...viewController.gameDetails.shipDetailList.count-1), id: \.self) { index in
                            Text("\(viewController.shipDetailList[index][2] as! Int)")
                        }
                    }.frame(minWidth: 0, maxWidth: gr.size.width*0.25).background(Color.white.opacity(0.5))
                    
                    VStack {
                        Text("\(viewController.game!.playerName2 ?? "???")").scaledToFit()
                        ForEach((0...viewController.gameDetails.shipDetailList.count-1), id: \.self) { index in
                            Text("\(viewController.shipDetailList[index][3] as! Int)")
                        }
                    }.frame(minWidth: 0, maxWidth: gr.size.width*0.35).background(Color.white.opacity(0.5))
                    
                    
                }.font(.system(size: 15, weight: .bold)).foregroundColor(Color(UIColor(hex: ColorValue.primary_dark)))
            }
        
    }
    
    // Draw water
    private func drawRectangleWithoutImage(position: Position) -> some View {
        if position == self.viewController.crossHairPosition {
            return AnyView(drawRectangleWithOneImage(position: position, imageName: "game_crosshair", rotation: 0))
        } else {
            return AnyView(
                Rectangle()
                    .fill(Color(UIColor(hex: ColorValue.primary_normal))
                    .opacity(0.8))
                    .border(Color.black, width: 1)
            )
        }
        
    }
    
    // Draw visible field or crosshair
    private func drawRectangleWithOneImage(position: Position, imageName: String, rotation: Double) -> some View {
        if position == self.viewController.crossHairPosition {
            return AnyView(drawRectangleWithTwoImages(position: position, shipImageName: imageName, rotationOfShipImage: rotation, otherImageName: "game_crosshair"))
        } else {
            return AnyView(
                Rectangle()
                    .fill(Color(UIColor(hex: ColorValue.primary_normal))
                    .opacity(0.8))
                    .overlay(Image(imageName).resizable().scaledToFit().rotationEffect(.degrees(rotation)))
                    .border(Color.black, width: 1)
            )
        }
    }
    
    // Draw ship with crosshair or if its visible
    private func drawRectangleWithTwoImages(position: Position, shipImageName: String, rotationOfShipImage: Double, otherImageName: String) -> some View {
        return Rectangle()
            .fill(Color(UIColor(hex: ColorValue.primary_normal))
            .opacity(0.8))
            .overlay(Image(shipImageName).resizable().scaledToFit().rotationEffect(.degrees(rotationOfShipImage)))
            .overlay(Image(otherImageName).resizable().scaledToFit())
            .border(Color.black, width: 1)
    }
    
    
    private func drawField(column: Int, row: Int, gridToDraw: FleetBattleGrid) -> some View {
        let position = Position(row: row, column: column)
        let currentField = gridToDraw.getField(pos: position) as! FleetBattleField
        // Ship
        if currentField.ship != nil {
            // Submerged ship
            if currentField.ship!.submerged == true {
                return AnyView(drawRectangleWithOneImage(position: position, imageName: "game_skull", rotation: 0))
            } else if currentField.isVisible {
                // Ship with explosion (own Grid)
                if gridToDraw.ownerUsername == AuthenticationService.getUsername()! {
                    
                    // Startposition
                    if currentField.ship!.startPosition == Position(row: row, column: column) {
                        
                        // Length 1
                        if currentField.ship!.length == 1 {
                            return AnyView(drawRectangleWithTwoImages(position: position, shipImageName: "ship_single", rotationOfShipImage: 0, otherImageName: "game_explosion"))
                        }
                        
                        // Horizontal
                        else if currentField.ship!.orientation == Orientation.HORIZONTAL {
                            return AnyView(drawRectangleWithTwoImages(position: position, shipImageName: "ship_end", rotationOfShipImage: 180, otherImageName: "game_explosion"))
                        } else {
                            // Vertical
                            return AnyView(drawRectangleWithTwoImages(position: position, shipImageName: "ship_end", rotationOfShipImage: -90, otherImageName: "game_explosion"))
                        }
                        // Endposition
                    } else if currentField.ship!.getLastPositionOfShip() == Position(row: row, column: column) {
                        // Horizontal
                        if currentField.ship!.orientation == Orientation.HORIZONTAL {
                            return AnyView(drawRectangleWithTwoImages(position: position, shipImageName: "ship_end", rotationOfShipImage: 0, otherImageName: "game_explosion"))
                        } else {
                            // Vertical
                            return AnyView(drawRectangleWithTwoImages(position: position, shipImageName: "ship_end", rotationOfShipImage: 90, otherImageName: "game_explosion"))
                        }
                        
                        // Middle
                    } else {
                        return AnyView(drawRectangleWithTwoImages(position: position, shipImageName: "ship_middle", rotationOfShipImage: 0, otherImageName: "game_explosion"))
                    }
                    
                } else {
                    // Only explosion (other Grid)
                    return AnyView(drawRectangleWithOneImage(position: position, imageName: "game_explosion", rotation: 0))
                }
                // Not found ship
            } else {
                // Own grid (show ship)
                if gridToDraw.ownerUsername == AuthenticationService.getUsername()! {
                    
                    // Length 1
                    if currentField.ship!.length == 1 {
                        return AnyView(drawRectangleWithOneImage(position: position, imageName: "ship_single", rotation: 0))
                    }
                    
                    // Startposition
                    else if currentField.ship!.startPosition == Position(row: row, column: column) {
                        // Horizontal
                        if currentField.ship!.orientation == Orientation.HORIZONTAL {
                            return AnyView(drawRectangleWithOneImage(position: position, imageName: "ship_end", rotation: 180))
                        } else {
                            // Vertical
                            return AnyView(drawRectangleWithOneImage(position: position, imageName: "ship_end", rotation: -90))
                        }
                        // Endposition
                    } else if currentField.ship!.getLastPositionOfShip() == Position(row: row, column: column) {
                        // Horizontal
                        if currentField.ship!.orientation == Orientation.HORIZONTAL {
                            return AnyView(drawRectangleWithOneImage(position: position, imageName: "ship_end", rotation: 0))
                        } else {
                            // Vertical
                            return AnyView(drawRectangleWithOneImage(position: position, imageName: "ship_end", rotation: 90))
                        }
                        
                        // Middle
                    } else {
                        return AnyView(drawRectangleWithOneImage(position: position, imageName: "ship_middle", rotation: 0))
                    }
                    
                    // Other grid (show water)
                } else {
                    return AnyView(drawRectangleWithoutImage(position: position))
                }
            }
            // Water (with watersplash and without)
        } else {
            if gridToDraw.getField(pos: Position(row: row, column: column)).isVisible {
                return AnyView(drawRectangleWithOneImage(position: position, imageName: "game_watersplash", rotation: 0))
            } else {
                return AnyView(drawRectangleWithoutImage(position: position))
            }
        }
    }
    
    func drawGrid() -> some View {
        let gridToDraw = self.viewController.getGridToDraw()
        return
            GeometryReader { gr in
                VStack(alignment: .center, spacing: 0) {
                    
                    ForEach(0..<gridToDraw.height, id: \.self) { row in
                        HStack(alignment: .center, spacing: 0) {
                            ForEach(0..<gridToDraw.width, id: \.self) { column in
                                Group {
                                    drawField(column: column, row: row, gridToDraw: gridToDraw)
                                        .frame(width: gr.size.width*0.9/CGFloat(gridToDraw.width), height: gr.size.width*0.9/CGFloat(gridToDraw.width))
                                        .onTapGesture { self.viewController.gridPositionClicked(row: row, column: column) }
                                }
                                    
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity)
                    }
                }.frame(minWidth: 0, maxWidth: .infinity)
            }
        
    }
    
    
    func drawStatusText() -> some View {
        let game = self.viewController.game!
        let text = self.viewController.statusText
        
        // Game is not ready
        if game.gridFromPlayer1 == nil || game.gridFromPlayer2 == nil {
            return VStack {
                Text("\(text)")
                    .bold()
                    .foregroundColor(Color(UIColor(hex: ColorValue.primary_dark))).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30)
                    .background(Color.gray.opacity(0.0))
            }
        }
        // Game is running
        let isItOwnTurn = (GameService.isUserPlayer1(game: game) && game.usersTurn == 1) || (GameService.isUserPlayer2(game: game) && game.usersTurn == 2)
        let colorName = isItOwnTurn ? ColorValue.primary_dark : ColorValue.secondary_dark
        return VStack {
            Text("\(text)")
                .bold()
                .foregroundColor(Color.white).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30)
                .background(Color(UIColor(hex: colorName)))
        }

    }
    
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        let date = dateFormatter.string(from: Date())
        let game = FleetBattleGame(fleetBattleGameDetails: GameService.getFleetBattleGameById(id: "1"), createdAt: date, mode: GameMode.MULTIPLAYER, playerName1: AuthenticationService.getUsername()!, difficultyLevel: nil)
        return GameView(game: game)
    }
}
