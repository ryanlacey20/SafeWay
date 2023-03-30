//
//  CheckInRequestsViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 11/02/2023.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

class CheckInRequestsViewController: UIViewController, UITableViewDataSource, CheckInRequestsTableViewCellDelegate {
    @IBOutlet var checkInRequestsTable: UITableView!

    let db = FirebaseFirestore.Firestore.firestore()
    var requests = [String: Any]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.getCheckInRequestData(){ requestsList in
            self.requests = requestsList
            self.checkInRequestsTable.reloadData()
        }
        checkInRequestsTable.dataSource = self
        checkInRequestsTable.reloadData()

        // Do any additional setup after loading the view.
    }

    func checkInButtonTapped(senderUsername: String) {
        Utilities.getCurrentUserName { username in
            let checkInRequestsRef = self.db.collection("users").document(username).collection("checkInRequests").document(senderUsername)

            checkInRequestsRef.delete { error in
                if let error = error {
                    print("Error deleting document: \(error)")
                } else {
                    print("Document successfully deleted.")
                    Utilities.getCheckInRequestData(){requestsList in
                        self.requests = requestsList
                        
                        self.checkInRequestsTable.reloadData()
                    }
                    self.checkInRequestsTable.reloadData()
                    self.db.collection("users").document(senderUsername).collection("checkInRequestsSent").document(username).setData(["checkedIn": true, "reciever": username, "timestamp": Timestamp()])
                }
            }
        }

    }



    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        
        return requests.count
    }

    func tableView(_ checkInRequestsTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = checkInRequestsTable.dequeueReusableCell(withIdentifier: "RequestsCell", for: indexPath) as! CheckInRequestsTableViewCell

        cell.delegate = self

        let senders = Array(requests.keys)
        let selectedSender = senders[indexPath.row]
        let selectedRequest = requests[selectedSender] as! [String: Any]

        let timeStamp = selectedRequest["timestamp"] as? Timestamp
        var timeStampAsDate = Date()
        if timeStamp != nil {
            timeStampAsDate = (timeStamp?.dateValue())!
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let dateAsString = dateFormatter.string(from: timeStampAsDate)

        cell.senderLabel.text = selectedRequest["sender"] as? String
        cell.senderUsername = selectedRequest["sender"] as? String ?? ""
        Utilities.getCurrentUserName { username in
            cell.userUsername = username
//            self.usernameLoaded = true
//            self.checkInRequestsTable.reloadData()
        }


        cell.timeRequestedLabel.text = dateAsString
            return cell
    }
}
