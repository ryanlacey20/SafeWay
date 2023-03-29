//
//  PanicMessagesTableViewCell.swift
//  BeSafe
//
//  Created by Ryan Lacey on 20/02/2023.
//

import UIKit
import Firebase
class PanicMessagesTableViewCell: UITableViewCell {
    var cellUser : [String:Any] = [:]
    
    @IBOutlet weak var sentAtLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func cellReloaded(){

        self.nameLabel.text = cellUser["sharingUsername"] as? String
        let timestamp = cellUser["sharedAt"] as! NSNumber
        let myDate = Date(timeIntervalSince1970: timestamp.doubleValue)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-d-yyyy h:mm a"
        let dateString = dateFormatter.string(from: myDate)
        self.sentAtLabel.text = dateString


    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
