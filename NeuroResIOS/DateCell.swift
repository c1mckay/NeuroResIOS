//
//  DateCell.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/22/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var backgroundCircle: UIView!
    @IBOutlet weak var rDot: UIView!
    
    func showEvents(){
        rDot.isHidden = false
    }
    
    func hideEvents(){
        rDot.isHidden = true
    }
}
