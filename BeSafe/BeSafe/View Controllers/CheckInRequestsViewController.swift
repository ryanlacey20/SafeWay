//
//  CheckInRequestsViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 11/02/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CheckInRequestsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var checkInRequestsTable: UITableView!
    var username = ""
    let db = FirebaseFirestore.Firestore.firestore()
    var requests = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRequestData()

        // Do any additional setup after loading the view.
    }
    
    func getRequestData(){

        db.collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.username = data["username"] as! String
                    
                    let checkInRequestsRef = self.db.collection("users").document(self.username).collection("checkInRequests")
                    
                    checkInRequestsRef.getDocuments {(querySnapshot, err) in
                        if err != nil {
                               print("Error getting documents")
                           } else {
                               guard let documents = querySnapshot?.documents else { return }
                               for document in documents {
                                   print("this is the document", document)
                                   self.requests.merge(document.data()) { (current, _) in current }
                                   print("this is waht uyoure wokring on now", self.requests)
                               }
                           }
     
                    }
                }
            }
        }
    }
    func tableView(_ friendsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    func tableView(_ friendsTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CheckinTableViewCell

//        let followingList = dataArray["following"] as! [String]
//        cell.textLabel?.text = followingList[indexPath.row]
//        cell.recievingUsername = followingList[indexPath.row]
//        cell.sendingUsername = self.username
//        cell.checkInStatusLabel.text = "poo"
        return cell
    }
}
