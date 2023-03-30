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
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sentAtLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func cellReloaded(){
        let name = cellUser["sharingUsername"] as! String
        self.nameLabel.text = name
        let timestamp = cellUser["sharedAt"] as! NSNumber
        let status = cellUser["status"] as! String
        self.statusLabel.text = "Panic level: \(status)"
        if status == "red"{
            statusLabel.textColor = .red
        } else {
            statusLabel.textColor = .yellow
        }
        let myDate = Date(timeIntervalSince1970: timestamp.doubleValue)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-d-yyyy h:mm a"
        let dateString = dateFormatter.string(from: myDate)
        self.sentAtLabel.text = dateString


    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.cellReloaded()
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
