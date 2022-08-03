//
//  LoginModelController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

protocol LoginViewControllerInterface {
    func redirectToMenuActivity()
    func showErrorMessage(message: String)
}

class LoginModelController {
    private let viewController: LoginViewControllerInterface
    init(viewController: LoginViewControllerInterface) {
        self.viewController = viewController
    }

    func onLoginClicked(email: String, password: String) {
        AuthenticationService.signIn(email: email, password: password) {
            result, error in
            if result != nil {
                self.viewController.redirectToMenuActivity()
            }

            if let message = error {
                self.viewController.showErrorMessage(message: message)
            }
        }
    }
}
