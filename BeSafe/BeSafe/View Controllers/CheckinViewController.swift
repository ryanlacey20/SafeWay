//
//  CheckinViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 05/02/2023.
//

import UIKit
import FirebaseFirestore
import UserNotifications
import FirebaseAuth

class CheckinViewController: UIViewController, UITableViewDataSource {
    

    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var checkInStatusLabel: UILabel!
    
    var dataArray = [String : Any]()
    var followingList = [String]()
    var username = "empty"
    
    let db = FirebaseFirestore.Firestore.firestore()
    
    let refreshControl = UIRefreshControl()

    @objc func refreshData() {
        getFollowingData()
        friendsTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        friendsTableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        friendsTableView.dataSource = self
        
        getFollowingData()
        
        self.friendsTableView.reloadData()
//        listenForCheckInFlag()

        
    }

    func getFollowingData(){

        db.collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.dataArray = data
                    self.followingList = data["following"] as! [String]
                    self.username = data["username"] as! String
                    self.friendsTableView.reloadData()
                    
                }
            }
        }
    }

    
// TABLE SET UP
    func tableView(_ friendsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followingList.count
    }

    func tableView(_ friendsTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CheckinTableViewCell
        
        let db = Firestore.firestore()
        let usersCollectionRef = db.collection("users")
        let usernameDocRef = usersCollectionRef.document("username")
        let checkInRequestsSentCollRef = usernameDocRef.collection("checkInRequestsSent")
        let recievingUserDocRef = checkInRequestsSentCollRef.document("recievinguser")

        recievingUserDocRef.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let checkedIn = document.data()?["checkedIn"] as? Bool else {
                print("Checked in field not found in document")
                return
            }
            
            // Handle checkedIn value here
            if checkedIn {
                print("User is checked in")
            } else {
                print("User is not checked in")
            }
        }

        
        let followingList = dataArray["following"] as! [String]
        cell.textLabel?.text = followingList[indexPath.row]
        cell.recievingUsername = followingList[indexPath.row]
        cell.sendingUsername = self.username
        cell.listenForCheckinFlag()
        return cell
    }

}
