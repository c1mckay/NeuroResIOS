//
//  ChatTableCell.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 2/27/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit

class ChatTableCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var content: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
