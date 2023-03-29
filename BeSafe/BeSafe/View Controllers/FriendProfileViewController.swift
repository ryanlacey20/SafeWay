//
//  FriendProfileViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 20/02/2023.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

class FriendProfileViewController: UIViewController {
    var username: String = ""
    var isSOSContact = Bool()
    var isFollowed = Bool()
    let db = FirebaseFirestore.Firestore.firestore()

    @IBOutlet weak var homeSafeLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var toggleAsSOSContactButton: UIButton!

    @IBOutlet var toggleFollowButton: UIButton!

    @IBAction func toggleUserAsSOS(_: Any) {
        if isSOSContact == false {
            addUserAsSOSContact(sosUsername: username)
        } else {
            removeUserAsSOSContact(sosUsernameToRemove: username)
        }
    }

    @IBAction func toggleFollowUser(_: Any) {
        Utilities.getCurrentUserName { loggedInUsername in
            if self.isFollowed == true {
                Utilities.unfollowUser(loggedInUser: (loggedInUsername), userToUnfollow: self.username) {}
            }
            else {
                Utilities.followUser(forUser: loggedInUsername, followUser: self.username)
            }
        }

    }

    // Function: Adds user as Sos contact
    func addUserAsSOSContact(sosUsername: String) {
        Utilities.getCurrentUserName { username in
            self.db.collection("users").document(username).updateData(["sosContacts": FieldValue.arrayUnion([sosUsername])])
        }
        
    }

    // Function: Remove user as SOS contact
    func removeUserAsSOSContact(sosUsernameToRemove: String) {
        Utilities.getCurrentUserName { username in
            self.db.collection("users").document(username).updateData(["sosContacts": FieldValue.arrayRemove([sosUsernameToRemove])])
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.getDataFromUser(user: username) { data in
            self.nameLabel.text = data["first_name"] as? String
            self.usernameLabel.text = self.username
        }

        // Listener for document of selected user
        Utilities.getCurrentUserName { loggedInUser in
            self.db.collection("users").document(loggedInUser).addSnapshotListener { documentSnapshot, _ in
                let sosContactsField = documentSnapshot?.get("sosContacts") as! [String]
                let followingField = documentSnapshot?.get("following") as! [String]
                if sosContactsField.contains(self.username) {
                    print("user is already an sos Contact")
                    self.toggleAsSOSContactButton.setTitle("Remove as SOS Contact", for: .normal)
                    self.isSOSContact = true

                } else {
                    self.toggleAsSOSContactButton.setTitle("Add as SOS Contact", for: .normal)
                    self.isSOSContact = false
                }
                if followingField.contains(self.username) {
                    self.toggleFollowButton.setTitle("Unfollow", for: .normal)
                    self.isFollowed = true
                } else {
                    self.toggleFollowButton.setTitle("Follow", for: .normal)
                    self.isFollowed = false
                }


            }
            self.db.collection("users").document(self.username).addSnapshotListener { documentSnapshot, _ in
                    if documentSnapshot?.get("markedHomeAt") as? Timestamp == nil {
                        self.homeSafeLabel.text = "User has never marked home safe"
                    }else{
                        let homeTimeStamp = documentSnapshot?.get("markedHomeAt") as! Timestamp
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm, dd/MM/yy"
    
                        let timestamp = homeTimeStamp.dateValue()
    
                        let dateString = dateFormatter.string(from: timestamp)
                        self.homeSafeLabel.text = "home safe at \(dateString)"
                    }
            }
        }

    }
    


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
