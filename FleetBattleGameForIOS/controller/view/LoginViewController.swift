//
//  LoginViewController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation

class LoginViewController: ObservableObject, LoginViewControllerInterface {
    
    @Published var isSignedIn = AuthenticationService.getUsername() != nil
    @Published var errorMessage: String = ""
    
    private var modelController: LoginModelController? = nil
    
    init() {
        modelController = LoginModelController(viewController: self)
    }
    
    func redirectToMenuActivity() {
        isSignedIn = AuthenticationService.getUsername() != nil
    }
    
    func showErrorMessage(message: String) {
        if message.starts(with: "There is no user record") {
            errorMessage = "Es gibt noch kein Nutzerkonto mit dieser E-Mail-Adresse."
        } else if message.starts(with: "The password is invalid") {
            errorMessage = "Leider ist dein eingegebenes Passwort falsch."
        } else if message.starts(with: "The email address is badly formatted") {
            errorMessage = "Die angegebe E-Mail-Adresse ist ungültig."
        } else {
            errorMessage = message
        }
    }
    
    /// View -> Model
    func onLoginClicked(email: String, password: String) {
        if !email.isEmpty && !password.isEmpty {
            modelController?.onLoginClicked(email: email, password: password)
        } else {
            showErrorMessage(message: "Bitte gib deine E-Mail-Adresse und Passwort ein.")
        }
    }
    

}
