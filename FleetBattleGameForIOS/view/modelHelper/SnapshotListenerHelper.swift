//
//  SnapshotListenerHelper.swift
//  FleetBattleGame
//
//  Created by FMA2 on 07.01.22.
//  Copyright © 2022 FMA2. All rights reserved.
//

import Firebase

class SnapshotListenerHelper: SnapshotListenerInterface {
    
    private let db = Firestore.firestore()
    private var snapshotRegistration: ListenerRegistration? = nil
    
    func startListening(id: String, callback: @escaping (FleetBattleGame?, String?) -> ()) {
        removeListener()
        let docRef = db.collection(FleetBattleGame.COLLECTION_NAME).document(id)
        snapshotRegistration = docRef.addSnapshotListener { result, error in
            if let document = result {
                if document.exists {
                    if let gameObject = FleetBattleGame.toObject(map: document.data()!) {
                        gameObject.documentId = document.documentID
                        callback(gameObject, nil)
                        return
                    }
                } else {
                    callback(nil, "Data object doesn't exist anymore")
                }
            }
            if let message = error {
                callback(nil, message.localizedDescription)
            }
        }
    }
    
    func removeListener() {
        snapshotRegistration?.remove()
    }
    
    
}
