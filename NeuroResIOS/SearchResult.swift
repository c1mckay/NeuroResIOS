//
//  SearchResult.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/12/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit

class SearchResult: UITableViewCell {

    @IBOutlet weak var resultText: UILabel!
    @IBOutlet weak var statusIco: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
