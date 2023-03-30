//
//  Utilities.swift
//  BeSafe
//
//  Created by Ryan Lacey on 13/11/2022.
//

import FirebaseAuth
import FirebaseFirestore
import Firebase
import Foundation
import UIKit

class Utilities {
    static let db = FirebaseFirestore.Firestore.firestore()
    
    static func isNameValid (_ name: String) -> Bool {
        let nameRegex = "^[a-zA-Z ]+$"
        let namePredicate = NSPredicate(format:"SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: name)
    }

    static func isUsernameValid(_ username: String) -> Bool {
        return !username.contains(" ")
    }

    
    static func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // function to test is the password secure enough
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }

    // function to get the username of the current user
    static func getCurrentUserName(completion: @escaping (String) -> Void) {
        let currentUser = Auth.auth().currentUser
        let currentUserUID = currentUser!.uid

        db.collection("users").whereField("uid", isEqualTo: currentUserUID).getDocuments { querySnapshot, error in
            if error == nil {
                let doc = querySnapshot?.documents.first
                let data = doc?.data()
                completion(data?["username"] as! String)
            } else {
                completion("no username found")
            }
        }
    }
    

    // function which gets the users followed by the parameter "forUser"
    static func getFollowersList(forUser _: String, completion: @escaping ([String]) -> Void) {
        self.getCurrentUserName() { username in
            db.collection("users").document(username).getDocument { user, _ in
                let data = user?.data()
                let followersList = data?["following"] as? [String]
                completion(followersList!)
            }
        }

    }

    static func getListFromSubcollection(user: String, subcollectionName: String, listKey: String, completion: @escaping ([String: Any]) -> Void) {
        var returnList: [String: Any] = [:]
        db.collection("users").document(user).collection(subcollectionName).getDocuments { querySnapshot, err in
            if let err = err {
                print("error retrieving list from subcollection \(err)")
            } else if let documents = querySnapshot?.documents {
                for document in documents {
                    let data = document.data()
                    returnList[data[listKey] as? String ?? "empty"] = data
                }
                completion(returnList)
            }
        }
    }

    static func getDataFromUser(user: String, completion: @escaping ([String: Any]) -> Void) {
        let trimmedUser = user.trimmingCharacters(in: .whitespacesAndNewlines)
        db.collection("users").document(trimmedUser).getDocument { docSnapshot, error in
            let data = docSnapshot!.data()
            completion(data!)
        }
    }

    static func unfollowUser(loggedInUser: String, userToUnfollow: String, completion _: @escaping () -> Void) {
        getFollowersList(forUser: loggedInUser) { followersList in
            var followersList = followersList
            followersList.removeAll(where: { $0 == userToUnfollow })
            db.collection("users").document(loggedInUser).updateData(["following": followersList])
        }
    }

    static func followUser(forUser: String, followUser: String) {
        db.collection("users").document(forUser).updateData(["following": FieldValue.arrayUnion([followUser])])
    }

    static func getSOSContacts(forUser: String, completion: @escaping ([String]) -> Void) {
        getCurrentUserName { username in
            db.collection("users").document(username).getDocument { user, _ in
                let data = user?.data()
                let sosContacts = data?["sosContacts"] as? [String]
                completion(sosContacts ?? [])
            }
        }

    }

    static func sendPanicMessageToUser(sendTo: String, fromUser: String) {
        let timestamp = Timestamp()
        let date = timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timestampString = dateFormatter.string(from: date)
        let panicDocumentName = "\(timestampString) \(fromUser)"
        db.collection("users").document(sendTo).collection("panicMessages").document(panicDocumentName).setData(["Test": "Complete"])
    }
    
    static func getPanicMessages(username: String, completion: @escaping ([String:Any]) -> Void){
        let databaseRef = Database.database(url: "https://besafe-fyp-default-rtdb.europe-west1.firebasedatabase.app").reference()

        databaseRef.child("user_locations").observe(.value, with: { snapshot in
            guard let data = snapshot.value as? [String: Any] else { return }

            
            let filteredData = data.filter { (nodeData) in
                let data = nodeData.value as! [String: Any]
                guard let sharedWithData = data["sharedWith"] as? Array<String> else {
                    getPanicMessages(username: username, completion: completion)
                    return false
                }
                    return (sharedWithData.contains(username))
                
            }
            completion(filteredData)
        })
    }
    static func isPanicMessages(username: String, completion: @escaping (Any) -> Void){
        let databaseRef = Database.database(url: "https://besafe-fyp-default-rtdb.europe-west1.firebasedatabase.app").reference()

        databaseRef.child("user_locations").observe(.value, with: { snapshot in
            guard let data = snapshot.value as? [String: Any] else { return }
            
            
            let filteredData = data.filter { (nodeData) in
                let data = nodeData.value as! [String: Any]
                guard let sharedWithData = data["sharedWith"] as? Array<String> else {
                    getPanicMessages(username: username, completion: completion)
                    return false
                }
                return (sharedWithData.contains(username))
                
            }
            if filteredData as? [String: String] == [:] {
                completion(false)
            }else {
                completion(true)
            }
        })
    }
    
}
