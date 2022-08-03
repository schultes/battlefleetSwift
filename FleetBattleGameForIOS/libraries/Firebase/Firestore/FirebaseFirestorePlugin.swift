//
//  FirestorePlugin.swift
//  PluginsForIOSLibrary
//
//  Created by FMA1 on 25.05.21.
//  Copyright © 2021 FMA1. All rights reserved.
//


import Foundation
import Firebase

/**
 This class contains, in addition to the ID of the document and the name of the associated Collection,
 also the stored data of the document itself
 - Parameter documentId: ID of the document
 - Parameter collectionName: Name of the associated collection
 - Parameter data: The stored data of the document as key-value pairs.
 */
public struct TPFirebaseFirestoreDocument {
    /// Document ID
    public let documentId: String
    /// Name of the associated collection
    public let collectionName: String
    /// The stored data of the document as key-value pairs
    public var data: [String: Any]
}

/**
 This class can be used to compose a query for Firestore.
 This query can be used to narrow down the scope of the requested documents.
 */
public class TPFirebaseFirestoreQueryBuilder {
    /// The name of the Collection from Firestore
    public let collectionName: String
    private var query: Query
    private let db = Firestore.firestore()
    
    /**
     Constructor
     - Parameter collectionName: the name of the collection of Firestore
     */
    public init(collectionName: String) {
        self.collectionName = collectionName
        self.query = db.collection(collectionName)
    }
    
    /**
     Filters a collection for documents where the array named `field` contains the value `value`.
     - Parameter field: attribute name of the array
     - Parameter value: value that must be contained in the array
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func whereArrayContains(field: String, value: Any) -> TPFirebaseFirestoreQueryBuilder {
        query = query.whereField(field, arrayContains: value)
        return self
    }
    
    /**
     Filters a collection for documents where the array named `field` contains one or more elements of the `value` array
     - parameter field: attribute name of the array
     - parameter value: array of possible values in the `field` array
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func whereArrayContainsAny(field: String, value: [Any]) -> TPFirebaseFirestoreQueryBuilder {
        query.whereField(field, arrayContainsAny: value)
        return self
    }
    
    /**
     Filters a collection for documents where the value of the field `field` corresponds to the passed value `value
     - Parameter field: Attribute name of the field
     - Parameter value: The value to find
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func whereEqualTo(field: String, value: Any) -> TPFirebaseFirestoreQueryBuilder {
        query = query.whereField(field, isEqualTo: value)
        return self
    }
    
    /**
     Filters a collection for documents where the value of the field `field` explicitly does not match the passed value `value`.
     - Parameter field: Attribute name of the field
     - Parameter value: The value that the field `field` must not have.
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func whereNotEqualTo(field: String, value: Any) -> TPFirebaseFirestoreQueryBuilder {
        query = query.whereField(field, isNotEqualTo: value)
        return self
    }
    
    /**
     Filters a collection for documents where the value of the field `field` is contained in the list `value
     - Parameter field: attribute name of the field
     - Parameter value: list of possible values that the field `field` may have
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func whereIn(field: String, value: [Any]) -> TPFirebaseFirestoreQueryBuilder {
        query = query.whereField(field, in: value)
        return self
    }
    
    /**
     Filters a collection for documents where the value of the field `field` is explicitly not contained in the list `value
     - Parameter field: attribute name of the field
     - Parameter value: list of possible values that the field `field` must not have
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func whereNotIn(field: String, value: [Any]) -> TPFirebaseFirestoreQueryBuilder {
        query = query.whereField(field, notIn: value)
        return self
    }
    
    /**
     Filters a collection for documents where the value of the field `field` is greater than the value `value`.
     - Parameter field: Attribute name of the field
     - Parameter value: The value to compare
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func whereGreaterThan(field: String, value: Any) -> TPFirebaseFirestoreQueryBuilder {
        query = query.whereField(field, isGreaterThan: value)
        return self
    }
    
    /**
     Filters a collection for documents where the value of the field `field` is greater than or equal to the value `value`.
     - Parameter field: Attribute name of the field
     - Parameter value: The value to compare
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func whereGreaterThanOrEqualTo(field: String, value: Any) -> TPFirebaseFirestoreQueryBuilder {
        query = query.whereField(field, isGreaterThanOrEqualTo: value)
        return self
    }
    
    /**
     Filters a collection for documents where the value of the field `field` is less than the value `value`.
     - Parameter field: Attribute name of the field
     - Parameter value: The value to compare
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func whereLessThan(field: String, value: Any) -> TPFirebaseFirestoreQueryBuilder {
        query = query.whereField(field, isLessThan: value)
        return self
    }
    
    /**
     Filters a collection for documents where the value of the field `field` is less than or equal to the value `value`.
     - Parameter field: Attribute name of the field
     - Parameter value: The value to compare
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func whereLessThanOrEqualTo(field: String, value: Any) -> TPFirebaseFirestoreQueryBuilder {
        query = query.whereField(field, isLessThanOrEqualTo: value)
        return self
    }
    
    /**
     Sorts the result set by the field `field`.
     (Default: Ascending sort)
     - Parameter field: Attribute name of the field
     - Parameter descending: Specifies whether the result set should be sorted in descending order
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func orderBy(field: String, descending: Bool = false) -> TPFirebaseFirestoreQueryBuilder {
        query = query.order(by: field, descending: descending)
        return self
    }
    
    /**
     Limits the result set in its scope
     - Parameter limit: Maximum number of elements in the result set
     - Returns: TPFirebaseFirestoreQueryBuilder
     */
    public func limit(limit: Int) -> TPFirebaseFirestoreQueryBuilder {
        query = query.limit(to: limit)
        return self
    }
    
    fileprivate func getCollectionName() -> String {
        return collectionName
    }
    
    fileprivate func getQuery() -> Query {
        return query
    }
}

/**
 * This class provides static methods for using Firestore.
 */
public struct TPFirebaseFirestore {
    private static let db = Firestore.firestore()
    
    /**
     Inserts a new document with the specified data into the specified collection.
     - Parameter collectionName: Name of the collection
     - Parameter data: The data to insert as key-value pairs.
     - Parameter callback: Callback for result return
     - Parameter result: Created document (in case of success)
     - Parameter error: Error message (in case of failure)
     # Reference TPFirebaseFirestoreDocument
     */
    public static func addDocument(
        collectionName: String,
        data: [String: Any],
        callback: @escaping (_ result: TPFirebaseFirestoreDocument?, _ error: String?) -> Void
    ) {
        var reference: DocumentReference? = nil
        reference = db.collection(collectionName).addDocument(data: data) {
            err in
            if let err = err {
                callback(nil, "\(err.localizedDescription)")
            } else {
                getDocument(collectionName: collectionName, documentId: reference!.documentID, callback: callback)
            }
        }
    }
    
    /**
     Creates or overwrites a document with the specified ID and data in the specified collection.
     - Parameter collectionName: Name of the collection
     - Parameter documentId: ID of the document
     - Parameter data: The data to insert as key-value pairs.
     - Parameter callback: callback for result return (only on failure)
     - Parameter error: Error message (on failure)
     */
    public static func setDocument(
        collectionName: String,
        documentId: String,
        data: [String: Any],
        callback: @escaping (_ error: String?)  -> Void
    ) {
        db.collection(collectionName).document(documentId).setData(data) {
            err in
            if let err = err {
                callback("\(err.localizedDescription)")
            } else {
                callback(nil)
            }
        }
    }
    
    /**
     Returns the document with the requested ID from the specified collection.
     - Parameter collectionName: name of the collection
     - Parameter documentId: ID of the document
     - Parameter callback: callback for result return
     - Parameter result: Requested document (in case of success)
     - Parameter error: Error message (in case of failure)
     # Reference TPFirebaseFirestoreDocument
     */
    public static func getDocument(
        collectionName: String,
        documentId: String,
        callback: @escaping (_ result: TPFirebaseFirestoreDocument?, _ error: String?) -> Void
    ) {
        var reference: DocumentReference? = nil
        
        reference = db.collection(collectionName).document(documentId)
        reference?.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let tpDocument = TPFirebaseFirestoreDocument(documentId: reference!.documentID, collectionName: collectionName, data: dataDescription ?? [String: Any]())
                callback(tpDocument, nil)
            } else {
                callback(nil, "\(error!.localizedDescription)")
            }
        }
    }
    
    /**
     Returns all documents of the specified collection.
     - Parameter collectionName: name of the collection
     - Parameter callback: callback for returning the result.
     - Parameter result: list of all documents of the specified collection (in case of success)
     - Parameter error: error message (in case of failure)
     # Reference TPFirebaseFirestoreDocument
     */
    public static func getDocuments(
        collectionName: String,
        callback: @escaping (_ result: [TPFirebaseFirestoreDocument]?, _ error: String?) -> Void
    ) {
        db.collection(collectionName).getDocuments { (querySnapshot, error) in
            if let error = error {
                callback(nil, "\(error.localizedDescription)")
            } else {
                var documentList = [TPFirebaseFirestoreDocument]()
                for document in querySnapshot!.documents {
                    documentList.append(TPFirebaseFirestoreDocument(documentId: document.documentID, collectionName: collectionName, data: document.data()))
                }
                callback(documentList, nil)
            }
        }
    }
    
    /**
     Returns all documents matching the set criteria of the `query` filter.
     - Parameter queryBuilder: Instance of TPFirebaseFirestoreQueryBuilder that sets filter criteria.
     - Parameter callback: callback for result return
     - Parameter result: list of documents matching the filter criteria (in case of success)
     - Parameter error: error message (in case of failure)
     # Reference TPFirebaseFirestoreQueryBuilder
     # Reference TPFirebaseFirestoreDocument
     */
    public static func getDocuments(
        queryBuilder: TPFirebaseFirestoreQueryBuilder,
        callback: @escaping (_ result: [TPFirebaseFirestoreDocument]?, _ error: String?) -> Void
    ) {
        queryBuilder.getQuery().getDocuments { (querySnapshot, error) in
            if let error = error {
                callback(nil, "\(error.localizedDescription)")
            } else {
                var documentList = [TPFirebaseFirestoreDocument]()
                for document in querySnapshot!.documents {
                    documentList.append(TPFirebaseFirestoreDocument(documentId: document.documentID, collectionName: queryBuilder.getCollectionName(), data: document.data()))
                }
                callback(documentList, nil)
            }
        }
    }
    
    /**
     Updates the fields contained in `data` of the document with the ID `documentId`. If the document does not exist, an error is returned.
     - Parameter collectionName: name of the collection
     - Parameter documentId: ID of the document
     - Parameter data: The updated data as key-value pairs.
     - Parameter callback: callback for result return (only on failure)
     - Parameter error: Error message (on failure)
     */
    public static func updateDocument(
        collectionName: String,
        documentId: String,
        data: [String: Any],
        callback: ((_ error: String?)  -> Void)? = nil
    ) {
        db.collection(collectionName).document(documentId).updateData(data) { err in
            if callback != nil {
                if err != nil {
                    callback!("\(err!.localizedDescription)")
                } else {
                    callback!(nil)
                }
            }
        }
    }
    
    /**
     Deletes the document with the specified ID from the specified collection.
     - Parameter collectionName: Name of the collection
     - Parameter documentId: ID of the document
     - Parameter callback: callback for result return (only on failure)
     - Parameter error: Error message (on failure)
     */
    public static func deleteDocument(
        collectionName: String,
        documentId: String,
        callback: ((_ error: String?)  -> Void)? = nil
    ) {
        db.collection(collectionName).document(documentId).delete() { err in
            if callback != nil {
                if err != nil {
                    callback!("\(err!.localizedDescription)")
                } else {
                    callback!(nil)
                }
            }
        }
    }
    
    /**
     Adds a SnapshotListener to a specified collection, which informs about changes in the collection with the help of the callback.
     - Parameter collectionName: Name of the collection
     - Parameter callback: callback for returning results when the SnapshotListener is added and when changes occur later on
     - Parameter result: list of all documents in the collection (in case of success)
     - Parameter error: error message (in case of failure)
     # Reference TPFirebaseFirestoreDocument
     */
    public static func addCollectionSnapshotListener(
        collectionName: String,
        callback: @escaping (_ result: [TPFirebaseFirestoreDocument]?, _ error: String?) -> Void
    ) {
        db.collection(collectionName).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                callback(nil, "\(error.localizedDescription)")
            } else {
                var documentList = [TPFirebaseFirestoreDocument]()
                for document in querySnapshot!.documents {
                    documentList.append(TPFirebaseFirestoreDocument(documentId: document.documentID, collectionName: collectionName, data: document.data()))
                }
                callback(documentList, nil)
            }
        }
        
    }
    
    /**
     Adds a SnapshotListener to a collection specified in queryBuilder, which uses the callback to notify about changes in the collection that match the set criteria of the `query` filter.
     - Parameter queryBuilder: Instance of TPFirebaseFirestoreQueryBuilder that sets filter criteria.
     - Parameter callback: callback for returning results when adding the SnapshotListener and when changes occur later on
     - Parameter result: list of all documents in the collection that match the filter criteria (if successful)
     - Parameter error: error message (in case of failure)
     # Reference TPFirebaseFirestoreQueryBuilder
     # Reference TPFirebaseFirestoreDocument
     */
    public static func addCollectionSnapshotListener(
        queryBuilder: TPFirebaseFirestoreQueryBuilder,
        callback: @escaping (_ result: [TPFirebaseFirestoreDocument]?, _ error: String?) -> Void
    ) {
        queryBuilder.getQuery().addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                callback(nil, "\(error.localizedDescription)")
            } else {
                var documentList = [TPFirebaseFirestoreDocument]()
                for document in querySnapshot!.documents {
                    documentList.append(TPFirebaseFirestoreDocument(documentId: document.documentID, collectionName: queryBuilder.getCollectionName(), data: document.data()))
                }
                callback(documentList, nil)
            }
        }
    }
    
    /**
     Adds a SnapshotListener to a document with the specified ID from the specified collection, which uses the callback to inform about changes to the document.
     - Parameter collectionName: Name of the collection
     - Parameter documentId: ID of the document
     - Parameter callback: callback for result return when adding the SnapshotListener and in case of later changes
     - Parameter result: Requested document (in case of success)
     - Parameter error: Error message (in case of failure)
     # Reference TPFirebaseFirestoreDocument
     */
    public static func addDocumentSnapshotListener(
        collectionName: String,
        documentId: String,
        callback: @escaping (_ result: TPFirebaseFirestoreDocument?, _ error: String?) -> Void
    ) {
        db.collection(collectionName).document(documentId).addSnapshotListener { (documentSnapshot, error) in
            if let err = error {
                callback(nil, "\(err.localizedDescription)")
            } else {
                let dataDescription = documentSnapshot!.data()
                let tpDocument = TPFirebaseFirestoreDocument(documentId: documentId, collectionName: collectionName, data: dataDescription ?? [String: Any]())
                callback(tpDocument, nil)
            }
        }
    }
}

