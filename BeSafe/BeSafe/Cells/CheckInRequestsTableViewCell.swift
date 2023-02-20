//
//  CheckInRequestsTableViewCell.swift
//  BeSafe
//
//  Created by Ryan Lacey on 11/02/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol CheckInRequestsTableViewCellDelegate: AnyObject {
    func checkInButtonTapped(senderUsername: String)
}

class CheckInRequestsTableViewCell: UITableViewCell {
    
    let db = FirebaseFirestore.Firestore.firestore()
    var userUsername = String()

    var senderUsername = String()
    weak var delegate: CheckInRequestsTableViewCellDelegate?
    
    @IBAction func checkInAsSafeButton(_ sender: Any) {
        
        delegate?.checkInButtonTapped(senderUsername: senderUsername)

    }
    
    @IBOutlet weak var senderLabel: UILabel!
    
    @IBOutlet weak var timeRequestedLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
