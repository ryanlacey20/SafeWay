//
//  CheckinTableViewCell.swift
//  BeSafe
//
//  Created by Ryan Lacey on 10/02/2023.
//

import FirebaseFirestore
import UIKit

class CheckinTableViewCell: UITableViewCell {
    var recievingUsername = ""{
        didSet {
            // This code block is called automatically after the value of myVariable is set or changed
            showHomeSafe()
            checkHomeSafe()
        }
}
    var hasCheckedin = false
    let db = FirebaseFirestore.Firestore.firestore()

    @IBOutlet var checkInStatusLabel: UILabel!

    @IBOutlet weak var nameLabel: UIButton!
    
    @IBOutlet var checkInButton: UIButton!

    @IBAction func checkInButtonPressed(_: Any) {
        Utilities.getCurrentUserName { sendingUsername in
            self.db.collection("users").document(self.recievingUsername).collection("checkInRequests").document(sendingUsername).setData(["sender": sendingUsername, "timestamp": Timestamp()])
            self.db.collection("users").document(sendingUsername).collection("checkInRequestsSent").document(self.recievingUsername).setData(["reciever": self.recievingUsername, "timestamp": Timestamp(), "checkedIn": false]) { error in
                if let error = error {
                    print("Error : \(error)")
                } else {
                    print("success.")
                    // TO DO: when table is reloaded the button is reset to check-in becuase it is not using data from the database
                    
                }
            }
        }
    }

    func showHomeSafe() {
        
        self.db.collection("users").document(recievingUsername).addSnapshotListener { documentSnapshot, _ in
            if documentSnapshot?.get("markedHomeAt") as? Timestamp == nil {
                self.nameLabel.setImage(nil, for: .disabled)
            } else if let markedHomeAt = documentSnapshot?.get("markedHomeAt") as? Timestamp {
                let currentTime = Timestamp(date: Date())
                if currentTime.seconds > markedHomeAt.seconds + 10 {
                    // More than 10 seconds have passed since markedHomeAt was set
                    self.nameLabel.setImage(nil, for: .disabled)
                } else {self.nameLabel.setImage(UIImage(systemName: "house"), for: .disabled)}
            }
            }
        }
    
    func checkHomeSafe(){
        self.db.collection("users").document(recievingUsername).getDocument { documentSnapshot, error in
            if documentSnapshot?.get("markedHomeAt") as? Timestamp == nil {
                self.nameLabel.setImage(nil, for: .disabled)
            } else if let markedHomeAt = documentSnapshot?.get("markedHomeAt") as? Timestamp {
                let currentTime = Timestamp(date: Date())
                if currentTime.seconds > markedHomeAt.seconds + 10 {
                    // More than 10 seconds have passed since markedHomeAt was set
                    self.nameLabel.setImage(nil, for: .disabled)
                } else {self.nameLabel.setImage(UIImage(systemName: "house"), for: .disabled)}
            }
            
        }
    }
    


    func listenForCheckinFlag(){
        Utilities.getCurrentUserName { sendingUsername in
            let docRef = self.db.collection("users").document(sendingUsername).collection("checkInRequestsSent").document(self.recievingUsername)
            docRef.addSnapshotListener{docSnapshot, error in
                if docSnapshot!.exists{
                    let data = docSnapshot?.data()
                    self.hasCheckedin = data!["checkedIn"] as! Bool
                    
                    if  self.hasCheckedin == false {
                        let timestamp = data?["timestamp"] as! Timestamp
                        let timestampAsDate = timestamp.dateValue()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm, dd/MM/yy"
                        let dateString = dateFormatter.string(from: timestampAsDate)
                        self.checkInStatusLabel.text = "\(self.recievingUsername) has not responded to checkin sent at \(dateString)"
                    } else {
                        let timestamp = data?["timestamp"] as! Timestamp
                        let timestampAsDate = timestamp.dateValue()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm, dd/MM/yy"
                        let dateString = dateFormatter.string(from: timestampAsDate)
                        self.checkInStatusLabel.text = "\(self.recievingUsername) checked in as safe at \(dateString)"
                    }
                } else { self.checkInStatusLabel.text = "Check in request has not been sent to \(self.recievingUsername)"}
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.setTitleColor(UIColor.label, for: .disabled)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
