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
    

//    @IBAction func checkInButton(_ sender: Any) {
//        let db = FirebaseFirestore.Firestore.firestore()
//        db.collection("users").document(username).collection("checkInRequests").document("ryanlacey").setData(["sender":username])
//    }
    
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
        listenForCheckInFlag()
        self.friendsTableView.reloadData()

//        await getFollowingData()
//        listenForCheckInFlag()
//        self.friendsTableView.reloadData()
        
        
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

    func listenForCheckInFlag(){

            let usersRef = Firestore.firestore().collection("users")
            let userRef = usersRef.document("ryanlacey")
            
            userRef.addSnapshotListener { (documentSnapshot, error) in
            if let document = documentSnapshot, document.exists {
                let checkInFlag = document.data()!["checkInFlag"] as! Bool
                if checkInFlag == true {
                    // Define an action that will be displayed in the notification.
                    let action = UNNotificationAction(identifier: "viewAction", title: "View", options: [.foreground])
                    
                    // Define a category that includes the action.
                    let category = UNNotificationCategory(identifier: "myCategory", actions: [action], intentIdentifiers: [], options: [])
                    
                    // Register the category with the notification center.
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                    
                    // Define the content of the notification.
                    let content = UNMutableNotificationContent()
                    content.title = "Checkin request"
                    content.body = "This is an alert notification."
                    content.categoryIdentifier = "myCategory"
                    
                    // Define the trigger for the notification.
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    
                    // Define the notification request and add it to the notification center.
                    let request = UNNotificationRequest(identifier: "myNotification", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            print("Notification scheduled.")
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    
}
    
// TABLE SET UP
    func tableView(_ friendsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followingList.count
    }

    func tableView(_ friendsTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CheckinTableViewCell

        let followingList = dataArray["following"] as! [String]
        cell.textLabel?.text = followingList[indexPath.row]
        cell.checkInStatusLabel.text = "poo"
        return cell
    }

}
