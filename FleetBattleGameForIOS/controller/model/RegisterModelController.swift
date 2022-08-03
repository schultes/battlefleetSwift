//
//  RegisterModelController.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

protocol RegisterViewControllerInterface {
    func redirectToMenuActivity()
    func showErrorMessage(message: String)
}

class RegisterModelController {
    private let viewController: RegisterViewControllerInterface
    init(viewController: RegisterViewControllerInterface) {
        self.viewController = viewController
    }

    func onRegisterClicked(email: String, password: String, displayName: String) {
        AuthenticationService.getUsersByDisplayname(displayName: displayName) {
            result, error in
            if let userlist = result {
                if userlist.isEmpty {
                    AuthenticationService.signUp(email: email, password: password, displayName: displayName) {
                        result, error in
                        if let user = result {
                            if let displayName = user.displayName {
                                TPFirebaseFirestore.addDocument(collectionName: User.COLLECTION_NAME, data: User.toMap(user: User(documentId: nil, username: displayName))) {
                                    result, error in
                                    if result != nil {
                                        self.viewController.redirectToMenuActivity()
                                    }
                                }
                            }
                        }

                        if let message = error {
                            self.viewController.showErrorMessage(message: message)
                        }
                    }
                } else {
                    self.viewController.showErrorMessage(message: "DisplayName is already used.")
                }
            }

            if error != nil {
                self.viewController.showErrorMessage(message: "Registration failed.")
            }
        }
    }
}
