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
        if isFollowed == true {
            Utilities.unfollowUser(loggedInUser: (Auth.auth().currentUser?.displayName)!, userToUnfollow: username) {}
        } else {
            Utilities.followUser(forUser: (Auth.auth().currentUser?.displayName)!, followUser: username)
        }
    }

    // Function: Adds user as Sos contact
    func addUserAsSOSContact(sosUsername: String) {
        db.collection("users").document((Auth.auth().currentUser?.displayName)!).updateData(["sosContacts": FieldValue.arrayUnion([sosUsername])])
    }

    // Function: Remove user as SOS contact
    func removeUserAsSOSContact(sosUsernameToRemove: String) {
        db.collection("users").document((Auth.auth().currentUser?.displayName)!).updateData(["sosContacts": FieldValue.arrayRemove([sosUsernameToRemove])])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.getDataFromUser(user: username) { data in
            self.nameLabel.text = data["first_name"] as? String
            self.usernameLabel.text = self.username
        }

        // Listener for document of selected user
        db.collection("users").document((Auth.auth().currentUser?.displayName)!).addSnapshotListener { documentSnapshot, _ in
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
