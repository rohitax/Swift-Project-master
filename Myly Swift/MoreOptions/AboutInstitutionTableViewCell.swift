//
//  AboutInstitutionTableViewCell.swift
//  Myly Swift
//
//  Created by Rohitax Rajguru on 06/07/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit

class AboutInstitutionTableViewCell: UITableViewCell {

    @IBOutlet weak var img_instituteImage: UIImageView!
    @IBOutlet weak var lbl_instituteName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
