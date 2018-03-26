//
//  EventCell.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/26/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var subtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
