//
//  StaffNameDescripCell.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/10/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit

class StaffNameDescripCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    let defautls = UserDefaults.standard
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            //print(name.text ?? "user")
            defautls.set(name.text!, forKey: "selected")
            
        }

    }

}
