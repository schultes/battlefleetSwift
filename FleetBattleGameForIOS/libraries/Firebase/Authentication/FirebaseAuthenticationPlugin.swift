//
//  FirebasePlugin.swift
//  PluginsForIOSLibrary
//
//  Created by FMA1 on 25.05.21.
//  Copyright © 2021 FMA1. All rights reserved.
//


import Foundation
import Firebase

/**
This class holds the data of the logged in user
 - Parameter uid: The unique ID of the user
 - Parameter email: The email address of the user
 - Parameter displayName: The display name of the user (not unique)
 - Parameter isEmailVerified: Indicates whether the user has verified their email address.
*/
public class TPFirebaseAuthenticationUser {
    /// The user's unique ID
    public var uid: String
    /// The user's email address
    public var email: String
    /// The display name of the user (not unique)
    public var displayName: String?
    /// Indicates whether the user has verified their email address
    public var isEmailVerified: Bool
    
     /**
     Constructor (can only be used by the TPFirebaseAuthentication library).
     - Parameter uid: The unique ID of the user
     - Parameter email: The email address of the user
     - Parameter displayName: The display name of the user (not unique)
     - Parameter isEmailVerified: Indicates whether the user has verified their email address.
     */
    fileprivate init(uid: String, email: String, displayName: String? = nil, isEmailVerified: Bool) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.isEmailVerified = isEmailVerified
    }
}

/**
 This class provides methods for authentication of a user
*/
public struct TPFirebaseAuthentication {
 
    /**
     Logging in a user with the help of his credentials.
     - Parameter email: User email address
     - Parameter password: user password
     - Parameter callback: callback for result return
     - Parameter user: User (In case of success)
     - Parameter error: Error message (In case of failure)
     # Reference TPFirebaseAuthenticationUser
     */
    public static func signIn(
        email: String,
        password: String,
        callback: @escaping(_ user: TPFirebaseAuthenticationUser?, _ error: String?) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in
            if let user = result?.user {
                let tpUser = TPFirebaseAuthenticationUser(uid: user.uid, email: user.email!, displayName: user.displayName, isEmailVerified: user.isEmailVerified)
                callback(tpUser, nil)
            } else {
                callback(nil, "\(error!.localizedDescription)")
            }
        })
    }
    
    /**
   Register a new user using an email address and password.
    - Parameter email: User email address
    - Parameter password: user password
    - Parameter callback: callback for result return
    - Parameter user: user (In case of success)
    - Parameter error: Error message (In case of failure)
    # Reference TPFirebaseAuthenticationUser
    */
    public static func signUp(
        email: String,
        password: String,
        callback: @escaping(_ user: TPFirebaseAuthenticationUser?, _ error: String?) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
            if let user = result?.user {
                let tpUser = TPFirebaseAuthenticationUser(uid: user.uid, email: user.email!, displayName: user.displayName, isEmailVerified: user.isEmailVerified)
                callback(tpUser, nil)
            } else {
                callback(nil, "\(error!.localizedDescription)")
            }
        })
    }
    
    /**
    Register a new user using an email address, password and display name.
    - Parameter email: User email address
    - Parameter password: user password
    - Parameter displayName: display name
    - Parameter callback: callback for result return
    - Parameter user: user (In case of success)
    - Parameter error: error message (In case of failure)
    # Reference TPFirebaseAuthenticationUser
    */
    public static func signUp(
        email: String,
        password: String,
        displayName: String,
        callback: @escaping(_ user: TPFirebaseAuthenticationUser?, _ error: String?) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
            if let firebaseUser = result?.user {
                let changeRequest = firebaseUser.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges(completion: { error in
                    if error == nil {
                        let tpUser = TPFirebaseAuthenticationUser(uid: firebaseUser.uid, email: firebaseUser.email!, displayName: displayName, isEmailVerified: firebaseUser.isEmailVerified)
                        callback(tpUser, nil)
                    } else {
                        let tpUser = TPFirebaseAuthenticationUser(uid: firebaseUser.uid, email: firebaseUser.email!, displayName: nil, isEmailVerified: firebaseUser.isEmailVerified)
                        callback(tpUser, "\(error!.localizedDescription)")
                    }
                })
            } else {
                callback(nil, "\(error!.localizedDescription)")
            }
        })
    }
    
    /**
     Logs out logged in user
    */
    public static func signOut() {
        do {
            try Auth.auth().signOut()
        } catch { }
    }
    
    /**
    Returns the currently logged in user, if none is logged in null is returned
     - Returns: Logged in user as TPFirebaseAuthenticationUser object
     # Reference TPFirebaseAuthenticationUser
     */
    public static func getUser() -> TPFirebaseAuthenticationUser? {
        if let firebaseUser = Auth.auth().currentUser {
            return TPFirebaseAuthenticationUser(uid: firebaseUser.uid, email: firebaseUser.email!, displayName: firebaseUser.displayName, isEmailVerified: firebaseUser.isEmailVerified)
        }
        return nil
    }
    
    /**
    Updates the email address of the currently logged in user.
    - Parameter email: User email address
    - Parameter callback: callback for result return (only on failure)
    - Parameter error: Error message (on failure)
    */
    public static func updateCurrentUserEmail(
        email: String,
        callback: @escaping(_ error: String?) -> Void
    ) {
        if isSignedIn() {
            Auth.auth().currentUser!.updateEmail(to: email, completion: { error in
                if error == nil {
                    callback(nil)
                } else {
                    callback("\(error!.localizedDescription)")
                }
            })
        } else {
            callback("No user signed in")
        }
    }
    
     /**
     Updates the display name of the currently logged in user
     - Parameter displayName: display name
     - Parameter callback: callback for result return (only on failure)
     - Parameter error: error message (on failure)
     */
    public static func updateCurrentUserDisplayName(
        displayName: String,
        callback: @escaping(_ error: String?) -> Void
    ) {
        if let firebaseUser = Auth.auth().currentUser {
            let changeRequest = firebaseUser.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges(completion: { error in
                if error == nil {
                    callback(nil)
                } else {
                    callback("\(error!.localizedDescription)")
                }
            })
        } else {
            callback("No user signed in")
        }
    }
    
     /**
    Deletes the currently logged in user and logs him out
     - Parameter callback: Callback for result return (only on failure)
     - Parameter error: Error message (on failure)
     */
    public static func deleteUser(
        callback: @escaping(_ error: String?) -> Void
    ) {
        if isSignedIn() {
            Auth.auth().currentUser!.delete(completion: { error in
                if error == nil {
                    callback(nil)
                } else {
                    callback("\(error!.localizedDescription)")
                }
            })
        }
    }
 
    /**
    Checks if a user is currently logged in
    - Returns: Whether the user is currently logged in as bool
    */
    public static func isSignedIn() -> Bool {
        return getUser() !== nil
    }
    
     /**
    Sends a message for verification to the email address of the currently logged in user
     - Parameter callback: Callback for result return (only in case of failure)
     - Parameter error: error message (in case of failure)
     */
    public static func sendEmailVerification(
        callback: @escaping(_ error: String?) -> Void
    ) {
        if isSignedIn() {
            Auth.auth().currentUser!.sendEmailVerification(completion: { error in
                if error == nil {
                    callback(nil)
                } else {
                    callback("\(error!.localizedDescription)")
                }
            })
        } else {
            callback("No user signed in")
        }
    }
    
     /**
     Sends a password reset message to the email address of the currently logged in user
     - Parameter callback: callback for result return (only in case of failure)
     - Parameter error: error message (in case of failure)
     */
    public static func sendPasswordResetEmail(
        callback: @escaping(_ error: String?) -> Void
    ) {
        if isSignedIn() {
            Auth.auth().sendPasswordReset(withEmail: getUser()!.email, completion: { error in
                if error == nil {
                    callback(nil)
                } else {
                    callback("\(error!.localizedDescription)")
                }
            })
        } else {
            callback("No user signed in")
        }
    }
}

