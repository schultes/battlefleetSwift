//
//  DatabaseService.swift
//  FleetBattleGame
//
//  Created by FMA2 on 29.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

class DatabaseService {
    static func saveFleetBattleGameObject(map: [String: Any], callback: @escaping (FleetBattleGame?, String?) -> ()) {
        TPFirebaseFirestore.addDocument(collectionName: FleetBattleGame.COLLECTION_NAME, data: map) {
            result, error in
            if let document = result {
                if let gameObject = FleetBattleGame.toObject(map: document.data) {
                    gameObject.documentId = document.documentId
                    callback(gameObject, nil)
                }
            }
            
            if let message = error {
                callback(nil, message)
            }
        }
    }
    
    static func updateFleetBattleGameObject(id: String, map: [String: Any], callback: @escaping (String?) -> ()) {
        TPFirebaseFirestore.updateDocument(collectionName: FleetBattleGame.COLLECTION_NAME, documentId: id, data: map) {
            error in
            callback(error)
        }
    }
    
    static func loadAllOpenFleetBattleGames(callback: @escaping ([FleetBattleGame]?, String?) -> ()) {
        let playerName1 = AuthenticationService.getUsername() != nil ? AuthenticationService.getUsername()! : ""
        let query = TPFirebaseFirestoreQueryBuilder(collectionName: FleetBattleGame.COLLECTION_NAME).whereEqualTo(field: "mode", value: GameMode.MULTIPLAYER.rawValue).whereEqualTo(field: "playerName2", value: "").whereEqualTo(field: "isFinished", value: false).whereNotEqualTo(field: "playerName1", value: playerName1)
        TPFirebaseFirestore.addCollectionSnapshotListener(queryBuilder: query) {
            result, error in
            if let list = result {
                var games = [FleetBattleGame]()
                for element in list {
                    if let temp = FleetBattleGame.toObject(map: element.data) {
                        temp.documentId = element.documentId
                        games.append(temp)
                    }
                }
                
                callback(games, nil)
            }
            
            if let message = error {
                callback(nil, message)
            }
        }
    }
    
    static func getAllRunningGamesFromUser(callback: @escaping ([FleetBattleGame]?, String?) -> ()) {
        let playerName1 = AuthenticationService.getUsername() != nil ? AuthenticationService.getUsername()! : ""
        let query = TPFirebaseFirestoreQueryBuilder(collectionName: FleetBattleGame.COLLECTION_NAME).whereEqualTo(field: "mode", value: GameMode.MULTIPLAYER.rawValue).whereEqualTo(field: "isFinished", value: false).whereArrayContains(field: "playerNames", value: playerName1).whereNotEqualTo(field: "playerName2", value: "")
        TPFirebaseFirestore.addCollectionSnapshotListener(queryBuilder: query) {
            result, error in
            if let list = result {
                var games = [FleetBattleGame]()
                for element in list {
                    if let temp = FleetBattleGame.toObject(map: element.data) {
                        temp.documentId = element.documentId
                        games.append(temp)
                    }
                }
                
                callback(games, nil)
            }
            
            if let message = error {
                callback(nil, message)
            }
        }
    }
    
    static func getAllOpenGameRequestsFromUser(callback: @escaping ([FleetBattleGame]?, String?) -> ()) {
        let playerName1 = AuthenticationService.getUsername() != nil ? AuthenticationService.getUsername()! : ""
        let query = TPFirebaseFirestoreQueryBuilder(collectionName: FleetBattleGame.COLLECTION_NAME).whereEqualTo(field: "mode", value: GameMode.MULTIPLAYER.rawValue).whereEqualTo(field: "playerName1", value: playerName1).whereEqualTo(field: "playerName2", value: "").whereEqualTo(field: "isFinished", value: false)
        TPFirebaseFirestore.addCollectionSnapshotListener(queryBuilder: query) {
            result, error in
            if let list = result {
                var games = [FleetBattleGame]()
                for element in list {
                    if let temp = FleetBattleGame.toObject(map: element.data) {
                        temp.documentId = element.documentId
                        games.append(temp)
                    }
                }
                
                callback(games, nil)
            }
            
            if let message = error {
                callback(nil, message)
            }
        }
    }
    
    static func deleteGameById(id: String) {
        TPFirebaseFirestore.deleteDocument(collectionName: FleetBattleGame.COLLECTION_NAME, documentId: id)
    }
    
    static func deleteOldSingleplayerGameOfUser() {
        let query = TPFirebaseFirestoreQueryBuilder(collectionName: FleetBattleGame.COLLECTION_NAME).whereEqualTo(field: "mode", value: GameMode.SINGLEPLAYER.rawValue).whereEqualTo(field: "playerName1", value: AuthenticationService.getUsername()!)
        TPFirebaseFirestore.getDocuments(queryBuilder: query) {
            result, error in
            if let list = result {
                for element in list {
                    self.deleteGameById(id: element.documentId)
                }
            }
        }
    }
    
    static func deleteFinishedMultiplayerGamesOfUser() {
        let query = TPFirebaseFirestoreQueryBuilder(collectionName: FleetBattleGame.COLLECTION_NAME).whereEqualTo(field: "mode", value: GameMode.MULTIPLAYER.rawValue).whereEqualTo(field: "isFinished", value: true).whereArrayContains(field: "playerNames", value: AuthenticationService.getUsername()!)
        TPFirebaseFirestore.getDocuments(queryBuilder: query) {
            result, error in
            if let list = result {
                for element in list {
                    self.deleteGameById(id: element.documentId)
                }
            }
        }
    }
    
    static func getOtherUsernames(callback: @escaping ([User]?, String?) -> ()) {
        let query = TPFirebaseFirestoreQueryBuilder(collectionName: User.COLLECTION_NAME).whereNotEqualTo(field: "username", value: AuthenticationService.getUsername()!)
        TPFirebaseFirestore.getDocuments(queryBuilder: query) {
            result, error in
            if let list = result {
                var user = [User]()
                for element in list {
                    if let tempUser = User.toObject(documentId: element.documentId, map: element.data) {
                        user.append(tempUser)
                    }
                }
                
                callback(user, nil)
            }
            
            if let message = error {
                callback(nil, message)
            }
        }
    }
}
