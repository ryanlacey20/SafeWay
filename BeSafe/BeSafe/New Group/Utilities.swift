//
//  Utilities.swift
//  BeSafe
//
//  Created by Ryan Lacey on 13/11/2022.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class Utilities{
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func getCurrentUserName(completion: @escaping (String?) -> Void) {
        let db = FirebaseFirestore.Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(nil)
            } else {
                if let firstName = querySnapshot?.documents.first?.data()["first_name"] as? String {
                    completion("Welcome \(firstName)")
                } else {
                    completion("Welcome blank")
                }
            }
        }
    }
    
    static func getFromDB(field : String, value: String, completion: @escaping ([String: Any]) -> Void) {
        let db = FirebaseFirestore.Firestore.firestore()
        let docRef = db.collection("users").whereField(field, isEqualTo: value).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    completion(document.data())
                }
            }
        }
    }


    
//    static func queryDB(field: String, queryValue: Any, completion: @escaping ([String : String]?) -> Void) {
//        let db = Firestore.firestore()
//        db.collection("users").whereField(field, isEqualTo: queryValue)
//            .getDocuments { (querySnapshot, error) in
//                if let error = error {
//                    print("Error querying DB: \(error)")
//                    completion(nil)
//                    return
//                }
//                guard let document = querySnapshot?.documents.first else {
//                    completion(nil)
//                    return
//                }
//                completion(document)
//            }
//    }
//
//
//    static func getCurrentUserUsername(completion: @escaping (Any?) -> Void) {
//        queryDB(field: "uid", queryValue: Auth.auth().currentUser?.uid) { data in
//            if data == nil {
//                print("No data returned from the query")
//                completion(nil)
//                return
//            }
//            // Use the data returned from the query
//            completion(data!["username"]!)
//        }
//    }
    
}
