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
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { docSnapshot, error in
            if let data = docSnapshot!.data(){
                completion(data["username"] as? String)
            }else {
                completion("no username found")
            }
        }
    }
    
    static func setUserInfoInConstants(username: String, completion: @escaping () -> Void) {
        Constants.currentUser.username = username
        Constants.currentUser.uid = Auth.auth().currentUser!.uid
    }
    
    //function which gets the users followed by the parameter "forUser"
    static func getFollowersList(forUser: String, completion: @escaping ([String]) -> Void) {
        db.collection("users").document(Constants.currentUser.username).getDocument { (user, error) in
            let data = user?.data()
            let followersList = data?["following"] as? [String]
            completion(followersList!)
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
    
    static func unfollowUser(loggedInUser: String, userToUnfollow: String, completion: @escaping () -> Void){
        self.getFollowersList(forUser: loggedInUser) { followersList in
            var followersList = followersList
            followersList.removeAll(where: {$0 == userToUnfollow})
            db.collection("users").document(loggedInUser).updateData(["following" : followersList])
        }
    }
    
    static func followUser(forUser: String, followUser: String){
        db.collection("users").document(forUser).updateData(["following": FieldValue.arrayUnion([followUser])])
    }

    static func getSOSContacts(forUser: String, completion: @escaping ([String]) -> Void){
        db.collection("users").document(Constants.currentUser.username).getDocument { (user, error) in
            let data = user?.data()
            let sosContacts = data?["sosContacts"] as? [String]
            completion(sosContacts ?? [])
        }
    }
    
    static func sendPanicMessageToUser(sendTo: String, fromUser: String){
        let timestamp = Timestamp()
        let date = timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timestampString = dateFormatter.string(from: date)
        let panicDocumentName = "\(timestampString) \(fromUser)"
        db.collection("users").document(sendTo).collection("panicMessages").document(panicDocumentName).setData(["Test" : "Complete"])
    }
    
}
