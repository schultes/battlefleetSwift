//
//  AuthenticationService.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

class AuthenticationService {
    static func signIn(email: String, password: String, callback: @escaping (TPFirebaseAuthenticationUser?, String?) -> ()) {
        TPFirebaseAuthentication.signIn(email: email, password: password) {
            result, error in
            if let user = result {
                callback(user, nil)
            }

            if let message = error {
                callback(nil, message)
            }
        }
    }

    static func signOut() {
        if TPFirebaseAuthentication.isSignedIn() {
            TPFirebaseAuthentication.signOut()
        }
    }

    static func getUsername() -> String? {
        return TPFirebaseAuthentication.getUser()?.displayName
    }
    
    static func signUp(email: String, password: String, displayName: String, callback: @escaping (TPFirebaseAuthenticationUser?, String?) -> ()) {
        TPFirebaseAuthentication.signUp(email: email, password: password, displayName: displayName) {
            result, error in
            if let user = result {
                callback(user, nil)
            }

            if let message = error {
                callback(nil, message)
            }
        }
    }

    static func getUsersByDisplayname(displayName: String, callback: @escaping ([TPFirebaseFirestoreDocument]?, String?) -> ()) {
        let query = TPFirebaseFirestoreQueryBuilder(collectionName: User.COLLECTION_NAME).whereEqualTo(field: "username", value: displayName)
        TPFirebaseFirestore.getDocuments(queryBuilder: query) {
            result, error in
            if let list = result {
                callback(list, nil)
            }

            if let message = error {
                callback(nil, message)
            }
        }
    }
}
