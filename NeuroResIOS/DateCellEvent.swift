//
//  DateCellEvent.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/29/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import UIKit

class DateCellEvent {
    
    var title: String
    var startTime, endTime: String?
    
    init(_ title_i: String, _ startTime_i: String?, _ endTime_i: String?){
        title = title_i
        startTime = startTime_i
        endTime = endTime_i
    }
}
