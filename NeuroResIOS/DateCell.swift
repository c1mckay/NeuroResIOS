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
    
    var daysEvents:[DateCellEvent] = []
    
    func setMarked(_ isSelected: Bool, _ cellState: CellState?){
        if(isSelected){
            eventBannerList.backgroundColor = AppDelegate.OFFWHITE
            backgroundCircle.backgroundColor = AppDelegate.OFFWHITE
        }else if(DateController.isToday(cellState!)){
            eventBannerList.backgroundColor = AppDelegate.UCSD_TEAL
            backgroundCircle.backgroundColor = AppDelegate.UCSD_TEAL
        }else{
            eventBannerList.backgroundColor = AppDelegate.UCSD_LIGHT_BLUE
            backgroundCircle.backgroundColor = AppDelegate.UCSD_LIGHT_BLUE
        }
    }
    
    func isMarked() -> Bool{
        return backgroundCircle.backgroundColor == AppDelegate.UCSD_YELLOW_ORANGE
    }
    
    
    
    func showEvent(_ dce: DateCellEvent){
        daysEvents.append(dce)
    }
    
    func clearEvents(){
        daysEvents.removeAll()
    }
    
    func update(){
        eventBannerList.reloadData()
    }
    
    //table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(4, daysEvents.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventbanner", for: indexPath) as! EventBanner
        cell.selectionStyle = .none
        cell.style()
        return cell
    }
}
