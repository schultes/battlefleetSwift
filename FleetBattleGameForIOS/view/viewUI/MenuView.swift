//
//  MenuView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    
    @ObservedObject var viewController = MenuViewController()
    @State private var showingAlert = false
    
    var body: some View {
        Group {
            if viewController.isSignedIn {
                ZStack {
                    Image("background_menu")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        HStack {
                            Spacer()
                            Button(action:  {
                                showingAlert = true
                            }) {
                                Image("navigation_logout")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal)))
                            }.padding(.trailing, 30)
                            .padding(.top, 30)
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            NavigationLink(destination: SingleplayerGameSettingsView()) {
                                Text("EINZELSPIELER")
                                    .padding(.vertical, 30)
                                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 65)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .background(Color(UIColor(hex: ColorValue.primary_normal)))
                                    .cornerRadius(10)
                            }.isDetailLink(false)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 80)
                            
                            NavigationLink(destination: OpenGamesView()) {
                                Text("MEHRSPIELER")
                                    .padding(.vertical, 30)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 65)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .background(Color(UIColor(hex: ColorValue.primary_normal)))
                                    .cornerRadius(10)
                            }.isDetailLink(false)
                            .padding(.horizontal, 50)
                            
                            Spacer()
                        }.padding(.top, -100)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(Texts.appName).font(.headline).foregroundColor(.white)
                        }
                    }
                }
            } else {
                LoginView()
            }
        }.alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Möchtest du dich wirklich ausloggen?"),
                message: nil,
                primaryButton: .destructive(Text("Ja")) {
                    self.viewController.signOut()
                },
                secondaryButton: .cancel(Text("Nein"))
            )
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
