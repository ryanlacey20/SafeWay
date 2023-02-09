//
//  CheckinViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 05/02/2023.
//

import UIKit
import FirebaseFirestore

class CheckinViewController: UIViewController, UITableViewDataSource {

   

    @IBOutlet weak var friendsTableView: UITableView!
    
    var dataArray = [String]()
//    var dataDummy = ["ryanddumdum", "dum2", "dum3"]

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.dataSource = self
        retrieveData()
    }

    func retrieveData() {
        db.collection("users").whereField("username", isEqualTo: "ryanlacey").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.dataArray = data["following"] as! [String]
                    print("this is data array", self.dataArray)
                    self.friendsTableView.reloadData()
                }
            }
        }
//        db.collection("users").whereField("username", isEqualTo: "ryanlacey").getDocuments { (querySnapshot, error) in
//            if let querySnapshot = querySnapshot {
//                for document in querySnapshot.documents {
//                    let data = document.data()
//                    self.dataArray.append(data)
//                }
//                self.friendsTableView.reloadData()
//            } else {
//                // Handle the error here
//            }
//        }
    }

    func tableView(_ friendsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ friendsTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let data = dataArray[indexPath.row]
        // Configure the cell with the data
        cell.textLabel?.text = data
        return cell
    }

}
