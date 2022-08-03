//
//  RegisterViewController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation

class RegisterViewController: ObservableObject, RegisterViewControllerInterface {
    
    @Published var isSignedIn = AuthenticationService.getUsername() != nil
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private var modelController: RegisterModelController? = nil
    
    init() {
        modelController = RegisterModelController(viewController: self)
    }
    
    func onRegisterClicked(username: String, email: String, password: String) {
        if username.isEmpty {
            showErrorMessage(message: "Bitte gib einen Nutzernamen ein")
        } else if username.contains(" ") {
            showErrorMessage(message: "Der Nutzername darf keine Leerzeichen enthalten")
        } else if email.isEmpty {
            showErrorMessage(message: "Bitte gib eine E-Mail-Adresse ein")
        } else if email.contains(" ") {
            showErrorMessage(message: "Die E-Mail-Adresse darf keine Leerzeichen enthalten")
        } else if password.isEmpty {
            showErrorMessage(message: "Bitte gib ein Passwort ein")
        } else if password.contains(" ") {
            showErrorMessage(message: "Das Passwort darf keine Leerzeichen enthalten")
        } else if username.count < 3 {
            showErrorMessage(message: "Dein Nutzername muss mindestens 3 Zeichen lang sein")
        } else if password.count < 5 {
            showErrorMessage(message: "Dein Passwort muss mindestens 5 Zeichen lang sein")
        } else {
            modelController?.onRegisterClicked(email: email, password: password, displayName: username)
        }
    }
    
    func redirectToMenuActivity() {
        isSignedIn = AuthenticationService.getUsername() != nil
    }
    
    func showErrorMessage(message: String) {
        showError = true
        if message.starts(with: "Displayname is already") {
            errorMessage = "Der Nutzername ist bereits vergeben"
        } else if message.starts(with: "The email address is badly formatted") {
            errorMessage = "Die angegebene E-Mail-Adresse ist ungültig"
        } else if message.starts(with: "The email address is already in use") {
            errorMessage = "Für die angegebene E-Mail-Adresse gibt es schon einen Account"
        } else {
            errorMessage = message
        }
    }
}
