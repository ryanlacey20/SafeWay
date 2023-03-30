//
//  CheckinViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 05/02/2023.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit
import UserNotifications

class CheckinViewController: UIViewController, UITableViewDataSource {
    @IBOutlet var friendsTableView: UITableView!

    
    var sendingUsername = String()

    var followingList = [String]()

    @IBOutlet weak var checkInButtonOutlet: UIButton!
    
    let db = FirebaseFirestore.Firestore.firestore()

    let refreshControl = UIRefreshControl()

    @objc func refreshData() {
        Utilities.getCurrentUserName() { username in
            Utilities.getFollowersList(forUser: username) { followersUsernames in
                self.followingList = followersUsernames
                self.friendsTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }


    }

    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.refreshControl = refreshControl
        
        Utilities.doesCheckInRequestExist{ bool in

            if !bool {
                Utilities.unreadItemStatus(itemToSetImage: self.checkInButtonOutlet, read: true)
                print("it shoudl be working")
            }else {
                Utilities.unreadItemStatus(itemToSetImage: self.checkInButtonOutlet, read: false)
                print("this means it shoudl be showing full crrilc")
            }
        }

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        friendsTableView.dataSource = self
        Utilities.getCurrentUserName() { username in
            
            self.sendingUsername = username
            Utilities.getFollowersList(forUser: (username)) { followersUsernames in
                self.followingList = followersUsernames
                
                self.friendsTableView.reloadData()
            }
        }


        friendsTableView.reloadData()

    }




    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return followingList.count
    }

    func tableView(_ friendsTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CheckinTableViewCell

//        let db = Firestore.firestore()
//        let usersCollectionRef = db.collection("users")
//        let usernameDocRef = usersCollectionRef.document("username")
//        let checkInRequestsSentCollRef = usernameDocRef.collection("checkInRequestsSent")
//        let recievingUserDocRef = checkInRequestsSentCollRef.document("recievinguser")
//
//        recievingUserDocRef.addSnapshotListener { documentSnapshot, error in
//            guard let document = documentSnapshot else {
//                print("Error fetching document: \(error!)")
//                return
//            }
//
//            guard let checkedIn = document.data()?["checkedIn"] as? Bool else {
//                print("Checked in field not found in document")
//                return
//            }
//
//            // Handle checkedIn value here
//            if checkedIn {
//                print("User is checked in")
//            } else {
//                print("User is not checked in")
//            }
//        }

        cell.nameLabel.text = followingList[indexPath.row]
        cell.recievingUsername = followingList[indexPath.row]

        
        cell.listenForCheckinFlag()
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "showFriendProfileSegue" {
            if let indexPath = friendsTableView.indexPathForSelectedRow {
                let selectedUser = followingList[indexPath.row]
                if let detailVC = segue.destination as? FriendProfileViewController {
                        detailVC.username = selectedUser
                    
                    
                }
            }
        }
    }
}
