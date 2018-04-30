//
//  EventBanner.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/29/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import UIKit

class EventBanner: UITableViewCell {

    @IBOutlet weak var bannerBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func style(){
        backgroundColor = UIColor(white: 1, alpha: 0.0)
        setCurvedEdges()
    }
    
    private func setCurvedEdges(){
        if(bannerBackground == nil){
            return
        }
        bannerBackground.layer.cornerRadius = 5
        bannerBackground.layer.masksToBounds = true
    }

}
