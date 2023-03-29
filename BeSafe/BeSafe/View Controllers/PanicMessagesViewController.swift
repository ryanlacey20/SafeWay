//
//  PanicMessagesViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 20/02/2023.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

class PanicMessagesViewController: UIViewController, UITableViewDataSource {
    var panicMessages = [String: Any]()
    var sharingUsers = [String]()
    @IBOutlet var panicMessagesTable: UITableView!
    
    @IBOutlet weak var timeSentLabel: UILabel!
    let db = FirebaseFirestore.Firestore.firestore()

    func tableView(_: UITableView , numberOfRowsInSection _: Int) -> Int {
        return panicMessages.count
    }

    func tableView(_ panicMessagesTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = panicMessagesTable.dequeueReusableCell(withIdentifier: "PanicMessageCell", for: indexPath) as! PanicMessagesTableViewCell
        
        sharingUsers = Array(panicMessages.keys)
        let selectedUser = sharingUsers[indexPath.row]
        print("selected user", selectedUser)
        cell.cellUser = panicMessages[selectedUser] as! [String : Any]
        cell.cellReloaded()
        return cell
    }

    override func viewDidLoad() {
        
        panicMessagesTable.dataSource = self
        super.viewDidLoad()
        Utilities.getCurrentUserName { username in
            Utilities.getPanicMessages(username: username){locationsShared in
                self.panicMessages = locationsShared
                self.panicMessagesTable.reloadData()
            }
        }

        

        

//        Utilities.getListFromSubcollection(user: (Auth.auth().currentUser?.displayName)!, subcollectionName: "panicMessages", listKey: "sender") { panicMessages in
//            self.panicMessages = panicMessages
//            self.panicMessagesTable.reloadData()
//        }

        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "showPanicMessageMap" {
            if let indexPath = panicMessagesTable.indexPathForSelectedRow {
                let selectedUser = sharingUsers[indexPath.row]
                let userData = panicMessages[selectedUser] as? [String: Any]
                if let detailVC = segue.destination as? PanicMessageMapViewController {
                    detailVC.username = selectedUser
                    detailVC.longitude = userData!["longitude"] as! Double
                    detailVC.latitude = userData!["latitude"] as! Double
                    
                    let timestamp = userData!["sharedAt"] as! NSNumber
                    let myDate = Date(timeIntervalSince1970: timestamp.doubleValue)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-d-yyyy h:mm a"
                    let dateString = dateFormatter.string(from: myDate)
                    detailVC.timeSent = dateString
                }
            }
        }
    }
}
