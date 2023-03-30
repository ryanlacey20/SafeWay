//
//  AddFriendsViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 19/01/2023.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

class AddFriendsViewController: UIViewController {
    let db = FirebaseFirestore.Firestore.firestore()
    var username = ""
    var userFoundFlag = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameSearch.text = ""
        self.followUserbutton.isHidden = true
        FirebaseFirestore.Firestore.firestore().collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.username = document.data()["username"] as! String
                }
            }
        }
    }

    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var usernameLabel: UILabel!

    @IBOutlet var followUserbutton: UIButton!

    @IBAction func searchBarEdited(_: Any) {
        db.collection("users").whereField("username", isEqualTo: usernameSearch.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    if let document = querySnapshot?.documents.first {
                        let fname = document.get("first_name") as! String
                        let lname = document.get("last_name") as! String
                        let username = document.get("username") as! String
                        
                        self.nameLabel.text = "\(fname) \(lname)"
                        self.usernameLabel.text = "\(username)"
                        
                        self.userFoundFlag = true
                        self.followUserbutton.isHidden = false
                        self.db.collection("users").document(self.username).getDocument{ docSnapshot, error in
                            let currentUserData = docSnapshot!.data()
                            if currentUserData!["following"] != nil {
                                let currentUsersFollowing = currentUserData!["following"] as! [String]
                                if currentUsersFollowing.contains(self.usernameSearch.text!.trimmingCharacters(in: .whitespacesAndNewlines)){
                                    self.followUserbutton.isEnabled = false
                                    self.followUserbutton.setTitle("Following", for: .disabled)
                                }else {
                                    self.followUserbutton.isEnabled = true
                                    self.followUserbutton.setTitle("follow user", for: .normal)
                                    self.nameLabel.text = "\(fname) \(lname)"

                                }
                            } else {
                                self.followUserbutton.isEnabled = true
                                self.followUserbutton.setTitle("follow user", for: .normal)
                                self.nameLabel.text = "\(fname) \(lname)"
                            }
                            
                        }
                    

                    } else {
                        self.nameLabel.text = ""
                        self.usernameLabel.text = ""
                        self.userFoundFlag = false
                        self.followUserbutton.isHidden = true
                    }
                }
            }
    }

    @IBOutlet var usernameSearch: UITextField!

    @IBAction func onFollowPress(_: Any) {
        if userFoundFlag == true {
            let currUserRef = db.collection("users").document(username)
            currUserRef.updateData(["following": FieldValue.arrayUnion([self.usernameSearch.text!.trimmingCharacters(in: .whitespacesAndNewlines)])])
            self.followUserbutton.isEnabled = false
            self.followUserbutton.setTitle("Following", for: .disabled)
        }
    }

    //hides keyboard when screen is tapped outside of keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
