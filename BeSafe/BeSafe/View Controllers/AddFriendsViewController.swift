//
//  AddFriendsViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 19/01/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AddFriendsViewController : UIViewController {
    
    let db = FirebaseFirestore.Firestore.firestore()
    var username = ""
    var userFoundFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseFirestore.Firestore.firestore().collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.username = document.data()["username"] as! String
                }
            }
    }
    }
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var followUserbutton: UIButton!
    
    @IBAction func searchBarEdited(_ sender: Any) {
        print("this was triggered")
        db.collection("users").whereField("username", isEqualTo: usernameSearch.text!)
                   .getDocuments { (querySnapshot, error) in
                       if let error = error {
                           print("Error getting documents: \(error)")
                       } else {
                           if let document = querySnapshot?.documents.first {
                               let fname = document.get("first_name") as! String
                               let lname = document.get("last_name") as! String
                               let username = document.get("username") as! String

                               self.nameLabel.text = "\(fname) \(lname)"
                               self.usernameLabel.text = "\(username)"
                               self.followUserbutton.setTitle("follow user", for: .normal)
                               self.nameLabel.text = "\(fname) \(lname)"
                               self.userFoundFlag = true
                
                               
                           } else {

                               self.nameLabel.text = ""
                               self.usernameLabel.text = ""
                               self.userFoundFlag = false
                           }
                       }
               }

    }
    
    @IBOutlet weak var usernameSearch: UITextField!
    
    
    @IBAction func onFollowPress(_ sender: Any) {
        if (userFoundFlag == true){
            let currUserRef = db.collection("users").document(self.username)
            currUserRef.updateData(["following": FieldValue.arrayUnion([usernameSearch.text])])
        }
    }
    
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
