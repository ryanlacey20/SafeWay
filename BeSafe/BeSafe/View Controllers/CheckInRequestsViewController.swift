//
//  CheckInRequestsViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 11/02/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CheckInRequestsViewController: UIViewController, UITableViewDataSource, CheckInRequestsTableViewCellDelegate {
    
    
    
    @IBOutlet weak var checkInRequestsTable: UITableView!
    var username = ""
    let db = FirebaseFirestore.Firestore.firestore()
    var requests = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRequestData()
        checkInRequestsTable.dataSource = self
        self.checkInRequestsTable.reloadData()
        if let navController = self.navigationController {
            print("here is nav controllersin requests", navController.viewControllers)
        }
        // Do any additional setup after loading the view.
    }
    func checkInButtonTapped(senderUsername: String) {
        let checkInRequestsRef = self.db.collection("users").document(self.username).collection("checkInRequests").document(senderUsername)

        checkInRequestsRef.delete(){ (error) in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Document successfully deleted.")
                self.getRequestData()
                self.checkInRequestsTable.reloadData()
                self.db.collection("users").document(senderUsername).collection("checkInRequestsSent").document(self.username).setData(["checkedIn": true, "reciever":self.username, "timestamp": Timestamp()])
            }
        }
        
    }
    
    func getRequestData(){
        
        self.requests = [:]
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
                                   let docData = document.data()
                                   self.requests[docData["sender"] as! String] = docData
                                   self.checkInRequestsTable.reloadData()
                               }
                           }
     
                    }
                }
            }
        }
    }
    func tableView(_ friendsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requests.count
    }

    func tableView(_ checkInRequestsTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = checkInRequestsTable.dequeueReusableCell(withIdentifier: "RequestsCell", for: indexPath) as! CheckInRequestsTableViewCell
        
        cell.delegate = self
        
        let senders = Array(self.requests.keys)
        let selectedSender = senders[indexPath.row]
        let selectedRequest = requests[selectedSender] as! [String: Any]
        
        let timeStamp = selectedRequest["timestamp"] as? Timestamp
        var timeStampAsDate = Date()
        if (timeStamp != nil) {
            timeStampAsDate = (timeStamp?.dateValue())!
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let dateAsString = dateFormatter.string(from: timeStampAsDate)
        
        cell.senderLabel.text = selectedRequest["sender"] as? String
        cell.senderUsername = selectedRequest["sender"] as? String ?? ""
        cell.userUsername = self.username

        cell.timeRequestedLabel.text = dateAsString
        return cell
    }
}
