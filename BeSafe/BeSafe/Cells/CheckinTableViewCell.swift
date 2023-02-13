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

    @IBOutlet weak var checkInStatusLabel: UILabel!
    

    @IBAction func checkInButtonPressed(_ sender: Any) {
        let db = FirebaseFirestore.Firestore.firestore()
        db.collection("users").document(recievingUsername).collection("checkInRequests").document(sendingUsername).setData(["sender":sendingUsername, "timestamp": Int(Date().timeIntervalSince1970)])
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
