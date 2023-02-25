//
//  CheckinTableViewCell.swift
//  BeSafe
//
//  Created by Ryan Lacey on 10/02/2023.
//

import UIKit
import FirebaseFirestore

class CheckinTableViewCell: UITableViewCell {
    var recievingUsername = ""
    var sendingUsername = ""
    var flag = false
    let db = FirebaseFirestore.Firestore.firestore()
    

    @IBOutlet weak var checkInStatusLabel: UILabel!
    
    @IBOutlet weak var checkInButton: UIButton!
    
    @IBAction func checkInButtonPressed(_ sender: Any) {
        db.collection("users").document(recievingUsername).collection("checkInRequests").document(sendingUsername).setData(["sender":sendingUsername, "timestamp":Timestamp()])
        db.collection("users").document(sendingUsername).collection("checkInRequestsSent").document(recievingUsername).setData(["reciever":recievingUsername, "timestamp":Timestamp(), "checkedIn": false]) {(error) in
            if let error = error {
                    print("Error : \(error)")
                } else {
                    print("success.")
                    //TO DO: when table is reloaded the button is reset to check-in becuase it is not using data from the database
                
                    self.checkInButton.setTitle("Request Sent", for: .disabled)
                    self.checkInButton.setTitle("Check-In", for: .normal)
                    self.checkInButton.isEnabled = false
                }
        }
    }
    
    //watcher
    func listenForCheckinFlag(){
        let docRef = db.collection("users").document(sendingUsername).collection("checkInRequestsSent")
        docRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    if document.exists {
                        // Get the value of the flag from the document data
                        let data = document.data()
                        let flagValue = data["checkedIn"] as? Bool ?? false
                        
                        // Check if the flag has changed
                        if flagValue != self.flag {
                            self.flag = flagValue
                            
                            // Execute different actions depending on the value of the flag
                            if self.flag {
                                // Flag is true
                                // Execute your first action
                            } else {
                                // Flag is false
                                // Execute your second action
                                self.checkInButton.isEnabled = true
                                self.db.collection("users").document(self.sendingUsername).collection("checkInRequestsSent").document(self.recievingUsername).getDocument(completion: { document, error in
                                    if let error = error {
                                            print("Error : \(error)")
                                        } else {
                                            let data = document?.data()
                                            
                                            let timestamp = data?["timestamp"] as! Timestamp
                                            let timestampAsDate = timestamp.dateValue()
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "HH:mm, dd/MM/yy"
                                            let dateString = dateFormatter.string(from: timestampAsDate)
                                            self.checkInStatusLabel.text = "Last Checked-in as safe at: \(dateString)"
                                        }
                                })
                            }
                        }
                    }
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
