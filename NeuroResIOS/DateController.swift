//
//  DateControllerViewController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/22/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var eventTable: UITableView!
    
    let formatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        eventTable.delegate = self
        eventTable.dataSource = self
        eventTable.backgroundColor = AppDelegate.OFFWHITE
        
        eventTable.estimatedRowHeight = 50
        eventTable.rowHeight = UITableViewAutomaticDimension
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.selectDates([ Date() ])
        calendarView.scrollToDate( Date(), animateScroll: false)
        
        calendarView.visibleDates { visibleDates in
            self.setupViewsOfCalendar(visibleDates)
        }
    }
    
    func getFutureDate() -> Date{
        let currentDate = Date()
        
        var dateComponent = DateComponents()
        dateComponent.year = 1
        
        return Calendar.current.date(byAdding: dateComponent, to: currentDate)!
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = Date()
        let endDate = getFutureDate()
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 1, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfRow,
            firstDayOfWeek: .sunday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomDateCell", for: indexPath) as! DateCell
        cell.dateLabel.text = cellState.text
        
        // Setup text color
        handleCellSelected(cellState, cell)
        handleCellTextColor(cellState, cell)
        
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.day, from: cellState.date)
        cell.clearEvents()
        if(myComponents.day! > 0){
            for i in 0 ... (2 * (myComponents.day! % 3)){
                cell.showEvent(DateCellEvent("NeuroResMeeting" + String(i), "8:00", "9:00"))
            }
            cell.update()
        }
        
        return cell
    }
    
    func handleCellSelected(_ cellState: CellState, _ cell : JTAppleCell?){
        guard let validCell = cell as? DateCell else {return}
        
        validCell.setMarked(validCell.isSelected, cellState)
    }
    
    static func isToday(_ cellState: CellState) -> Bool{
        let formatter = DateFormatter()
        formatter.dateFormat="yyyyMMdd"
        
        let todaysDateStr = formatter.string(from: Date())
        let cellDateStr = formatter.string(from: cellState.date)
        return todaysDateStr == cellDateStr
    }
    
    func handleCellTextColor(_ cellState: CellState, _ cell: JTAppleCell?){
        guard let validCell = cell as? DateCell else {return}
        
        if(!validCell.isMarked() && DateController.isToday(cellState)){
            validCell.dateLabel.textColor = UIColor.black
            //validCell.hideEvents()
        }else{
            if(validCell.isMarked()){
                validCell.dateLabel.textColor = UIColor.black
            }else{
                if cellState.dateBelongsTo == .thisMonth {
                    validCell.dateLabel.textColor = AppDelegate.UCSD_DARK_BLUE
                } else {
                    validCell.dateLabel.textColor = AppDelegate.UCSD_DARK_BLUE
                }
            }
        }
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? DateCell else {return}
        
        if(cellState.isSelected && validCell.isMarked()){
            validCell.setMarked(false, cellState)
        }else{
            handleCellSelected(cellState, cell)
        }
        
        handleCellTextColor(cellState, cell)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        handleCellSelected(cellState, cell)
        handleCellTextColor(cellState, cell)
    }
    
    func setupViewsOfCalendar(_ visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = self.formatter.string(from: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo){
        setupViewsOfCalendar(visibleDates);
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {}
    
    //table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.selectionStyle = .none
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

