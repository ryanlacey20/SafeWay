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
    static let db = FirebaseFirestore.Firestore.firestore()
    
    //function to test is the password secure enough
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    //function to get the username of the current user
    static func getCurrentUserName(completion: @escaping (String?) -> Void) {
        let db = FirebaseFirestore.Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(nil)
            } else {
                if let username = querySnapshot?.documents.first?.data()["username"] as? String {
                    completion(username)
                } else {
                    completion("Welcome blank")
                }
            }
        }
    }
    
    //function which gets the users followed by the parameter "forUser"
    static func getFollowersList(forUser: String, completion: @escaping (String?) -> Void) {
        db.collection("users").document(Constants.currentUser.username).getDocument { (user, error) in
            let data = user?.data()
            let followersList = data?["following"] as? String
            completion(followersList)
        }
    }
    
    
    static func getListFromSubcollection(user: String, subcollectionName: String, listKey: String, completion: @escaping ([String : Any])->Void){
        var returnList: [String:Any] = [:]
        db.collection("users").document(user).collection(subcollectionName).getDocuments { (querySnapshot, err) in
            if let documents = querySnapshot?.documents{
                    for document in documents {
                        let data = document.data()
                        returnList[data[listKey] as! String] = data
                    }
                completion(returnList)
                
            }
        }
    }
    
    static func getDataFromUser(user: String, completion: @escaping ([String:Any])->Void ){
        db.collection("users").document(user).getDocument { doc, error in
            if let data = doc?.data(){
                completion(data)
            }
        }
    }


    
}
