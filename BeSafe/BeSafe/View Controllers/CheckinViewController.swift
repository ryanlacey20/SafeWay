//
//  CheckinViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 05/02/2023.
//

import UIKit
import FirebaseFirestore
import UserNotifications

class CheckinViewController: UIViewController, UITableViewDataSource {
    

   

    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var checkInStatusLabel: UILabel!
    
    var dataArray = [String : Any]()
    var followingList = [String]()

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.dataSource = self
        getFollowingData()
        listenForCheckInFlag()
    }

    func getFollowingData() {
        db.collection("users").whereField("username", isEqualTo: "ryanlacey").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.dataArray = data
                    self.followingList = data["following"] as! [String]
                    print("this is data array", self.dataArray)
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
                print("this is the checkin flagydaggy", checkInFlag)
                if checkInFlag == true {
//                    let content = UNMutableNotificationContent()
//                    content.title = "Check-in successful!"
//                    content.body = "The check-in flag for has been set to true."
//
//                    let request = UNNotificationRequest(identifier: "CheckInSuccessful", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false))
//                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//                    self.scheduleCheckInFlagNotification()
                }
            } else {
                print("Document does not exist")
            }
        }
        
    }
    

    func scheduleCheckInFlagNotification() {
        // 1. Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Check-in Required"
        content.body = "Please check in to lower the flag."

        // 2. Create a trigger for the notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 3. Create a request for the notification
        let request = UNNotificationRequest(identifier: "CheckInFlagNotification", content: content, trigger: trigger)

        // 4. Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error adding notification request: \(error)")
            }
        }
    }

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
