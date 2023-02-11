//
//  CheckinTableViewCell.swift
//  BeSafe
//
//  Created by Ryan Lacey on 10/02/2023.
//

import UIKit

class CheckinTableViewCell: UITableViewCell {

    @IBOutlet weak var checkInStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
