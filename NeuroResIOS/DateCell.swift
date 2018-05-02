//
//  DateCell.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/22/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCell: JTAppleCell, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak private var backgroundCircle: UIView!
    @IBOutlet weak var eventBannerList: UITableView!
    
    var daysEvents = [Event]()
    var currentDate : Date?
    
    static var CALENDAR_OFFWHITE = AppDelegate.uicolorFromHex(rgbValue: 0xF0F3FF)
    static var CALENDAR_TODAY    = AppDelegate.uicolorFromHex(rgbValue: 0xFFED80)
    static var CALENDAR_SELECTED = AppDelegate.uicolorFromHex(rgbValue: 0xD1D1D1)//AppDelegate.UCSD_DARK_BLUE
    
    func setMarked(_ isSelected: Bool, _ cellState: CellState?){
        if(isSelected){
            eventBannerList.backgroundColor = DateCell.CALENDAR_SELECTED
            backgroundCircle.backgroundColor = DateCell.CALENDAR_SELECTED
        }else if(DateController.isToday(cellState!)){
            eventBannerList.backgroundColor = DateCell.CALENDAR_TODAY
            backgroundCircle.backgroundColor = DateCell.CALENDAR_TODAY
        }else{
            eventBannerList.backgroundColor = DateCell.CALENDAR_OFFWHITE
            backgroundCircle.backgroundColor = DateCell.CALENDAR_OFFWHITE
        }
        
        eventBannerList.reloadData()
    }
    
    func isMarked() -> Bool{
        return backgroundCircle.backgroundColor == DateCell.CALENDAR_SELECTED
    }
    
    func update(_ newEvents: [Event], currentDate_o: Date){
        self.daysEvents = newEvents
        eventBannerList.reloadData()
        self.currentDate = currentDate_o
    }
    
    //table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(4, daysEvents.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventbanner", for: indexPath) as! EventBanner
        cell.selectionStyle = .none
        cell.style()
        cell.setMarked(isMarked())
        cell.titleText.text = daysEvents[indexPath.row]._title
        cell.timeText.text = daysEvents[indexPath.row].getShortTimeText(currentDate)
        return cell
    }
}
