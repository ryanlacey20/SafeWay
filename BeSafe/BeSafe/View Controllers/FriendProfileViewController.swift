//
//  FriendProfileViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 20/02/2023.
//

import UIKit
import FirebaseFirestore

class FriendProfileViewController: UIViewController {

    var username: String = ""
    var isSOSContact = Bool()
    var isFollowed = Bool()
    let db = FirebaseFirestore.Firestore.firestore()
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var toggleAsSOSContactButton: UIButton!
    
    @IBOutlet weak var toggleFollowButton: UIButton!
    
    @IBAction func toggleUserAsSOS(_ sender: Any) {
        if self.isSOSContact == false{
            addUserAsSOSContact(sosUsername: self.username)
        }else{
            removeUserAsSOSContact(sosUsernameToRemove: self.username)
        }
    }
    
    @IBAction func toggleFollowUser(_ sender: Any) {
        if self.isFollowed == true{
            Utilities.unfollowUser(loggedInUser: Constants.currentUser.username, userToUnfollow: self.username){
                
            }}else{
                Utilities.followUser(forUser: Constants.currentUser.username, followUser: self.username)
            }
        
    }
    
    //Function: Adds user as Sos contact
    func addUserAsSOSContact(sosUsername: String){
        self.db.collection("users").document(Constants.currentUser.username).updateData(["sosContacts": FieldValue.arrayUnion([sosUsername])])
        
    }
    
    //Function: Remove user as SOS contact
    func removeUserAsSOSContact(sosUsernameToRemove: String){
        self.db.collection("users").document(Constants.currentUser.username).updateData(["sosContacts" : FieldValue.arrayRemove([sosUsernameToRemove])])
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.getDataFromUser(user: self.username) { data in
            self.nameLabel.text = data["first_name"] as? String
            self.usernameLabel.text = self.username
        }
        


        
        
        //Listener for document of selected user
        db.collection("users").document(Constants.currentUser.username).addSnapshotListener { documentSnapshot, error in
            let sosContactsField = documentSnapshot?.get("sosContacts") as! [String]
            let followingField = documentSnapshot?.get("following") as! [String]
            if sosContactsField.contains(self.username){
                print("user is already an sos Contact")
                self.toggleAsSOSContactButton.setTitle("Remove as SOS Contact", for: .normal)
                self.isSOSContact = true
                
                
            }else {
                self.toggleAsSOSContactButton.setTitle("Add as SOS Contact", for: .normal)
                self.isSOSContact = false
            }
            if followingField.contains(self.username){
                self.toggleFollowButton.setTitle("Unfollow", for: .normal)
                self.isFollowed = true
            }else {
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
