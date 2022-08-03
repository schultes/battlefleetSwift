//
//  RegisterView.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewController = RegisterViewController()
    @State var email: String = ""
    @State var password: String = ""
    @State var username: String = ""
    var body: some View {
        Group {
            if !viewController.isSignedIn {
                ZStack {
                    Image("background_menu")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                    GeometryReader { gr in
                        VStack {
                            Spacer()
                            Text("Registrierung")
                                .padding(.bottom, 20)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal)))
                            
                            TextField("", text: $username)
                                .padding(8)
                                .frame(minWidth: 200, maxWidth: 300)
                                .font(.system(size: 15))
                                .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                                .textContentType(.emailAddress)
                                .keyboardType(.default)
                                .compositingGroup()
                                .shadow(radius: 5)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                .textFieldStyle(BottomLineTextFieldStyle())
                                .placeholder(when: username.isEmpty) {
                                    Text("Nutzername").foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                                        .padding(8).font(.system(size: 15)).padding(.horizontal, 20)
                                        .padding(.bottom, 10)
                                }
                            
                            TextField("", text: $email)
                                .padding(8)
                                .frame(minWidth: 200, maxWidth: 300)
                                .font(.system(size: 15))
                                .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .compositingGroup()
                                .shadow(radius: 5)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                .textFieldStyle(BottomLineTextFieldStyle())
                                .placeholder(when: email.isEmpty) {
                                    Text("Email").foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                                        .padding(8).font(.system(size: 15)).padding(.horizontal, 20)
                                        .padding(.bottom, 10)
                                }
                            
                            SecureField("", text: $password)
                                .frame(minWidth: 200, maxWidth: 300)
                                .padding(8)
                                .font(.system(size: 15))
                                .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                                .compositingGroup()
                                .shadow(radius: 5)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .textFieldStyle(BottomLineTextFieldStyle())
                                .placeholder(when: password.isEmpty) {
                                    Text("Passwort").foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                                        .padding(8).font(.system(size: 15)).padding(.horizontal, 20)
                                    
                                }
                            
                            Text(viewController.errorMessage)
                                .font(.system(size: 12, weight: .bold))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(Color(UIColor(hex: ColorValue.secondary_normal)))
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                                .padding(.vertical, 10).padding(.horizontal, 28)
                            
                            Button(action:  {
                                self.viewController.onRegisterClicked(username: self.username, email: self.email, password: self.password)
                            }) {
                                Text("REGISTRIEREN")
                                    .frame(minWidth: 0, maxWidth: 180, minHeight: 40, maxHeight: 40)
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                                    .background(Color(UIColor(hex: ColorValue.primary_normal)))
                                    .cornerRadius(8)
                            }
                            
                            LabelledDivider(label: "oder", color: Color(UIColor(hex: ColorValue.secondary_normal))).font(.system(size: 14, weight: .bold))
                                .padding(.top, 10)
                                .padding(.bottom, 10)
                            
                            NavigationLink(destination: LoginView()) {
                                Text("ANMELDEN")
                                    .frame(minWidth: 0, maxWidth: 180)
                                    .frame(height: 40)
                                    .font(.system(size: 14, weight: .bold)) .foregroundColor(Color(UIColor(hex: ColorValue.primary_normal)))
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }.isDetailLink(false).padding(.horizontal, 80)
                            
                            Spacer()
                        }.frame(minWidth: gr.size.width * 0.9, maxWidth: gr.size.width, minHeight: gr.size.height * 0.9, maxHeight: gr.size.height * 0.9)
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
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            } else {
                MenuView()
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
