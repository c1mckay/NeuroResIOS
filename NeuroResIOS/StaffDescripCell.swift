//
//  StaffDescripCell.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/5/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit

class StaffDescripCell: UITableViewCell {
    @IBOutlet weak var expander: UIImageView!

    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
