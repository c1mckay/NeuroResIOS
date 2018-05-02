//
//  DateControllerViewController.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 3/22/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SwiftyJSON

class DateController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var eventTable: UITableView!
    
    let formatter = DateFormatter()
    
    var events = [Event]()
    
    
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
        
        calendarView.visibleDates { visibleDates in
            self.setupViewsOfCalendar(visibleDates)
        }
        
        DateController.getEvents { (events_ret: [Event]) in
            self.events = events_ret
            self.calendarView.reloadData()
            self.eventTable.reloadData()
            
            self.calendarView.selectDates([ Date() ])
            self.calendarView.scrollToDate( Date(), animateScroll: false)
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
        if(myComponents.day! > 0){
            cell.update(filterEvents(cellState.date), currentDate_o: date)
        }
        
        return cell
    }
    
    func filterEvents(_ selectedDate: Date) -> [Event]{
        var ret = [Event]()
        
        for e in self.events{
            if(e.contains(selectedDate)){
                ret.append(e)
            }
        }
        return ret
    }
    
    func handleCellSelected(_ cellState: CellState, _ cell : JTAppleCell?){
        guard let validCell = cell as? DateCell else {return}
        
        validCell.setMarked(validCell.isSelected, cellState)
        self.eventTable.reloadData()
    }
    
    static func isToday(_ cellState: CellState) -> Bool{
        return DateController.isSameDay(Date(), cellState.date)
    }
    
    func handleCellTextColor(_ cellState: CellState, _ cell: JTAppleCell?){
        guard let validCell = cell as? DateCell else {return}
        
        if(!validCell.isMarked() && DateController.isToday(cellState)){
            validCell.dateLabel.textColor = UIColor.black
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
    
    func getSelectedEvents() -> [Event]{
        if(self.calendarView.selectedDates.count == 0){
            return [Event]()
        }
        return filterEvents(self.calendarView.selectedDates[0])
        
    }
    
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool{
        let formatter = DateFormatter()
        formatter.dateFormat="yyyyMMdd"
        
        let todaysDateStr = formatter.string(from: date1)
        let cellDateStr = formatter.string(from: date2)
        return todaysDateStr == cellDateStr
    }
    
    //table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSelectedEvents().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        let selectedEvent = getSelectedEvents()[indexPath.row]
        cell.selectionStyle = .none
        cell.title.text     = selectedEvent._title
        cell.location.text  = selectedEvent._location
        cell.subtitle.text  = selectedEvent.getDescription()
        cell.time.text      = selectedEvent.getLongTimeText()
        return cell
    }
    
    static func getEvents(completion: @escaping (_: [Event]) -> Void ) {
        
        var events:[Event] = []
        
        let userGroup = DispatchGroup()
        var request = URLRequest(url: URL(string: AppDelegate.BASE_URL + "get_events")!)
        request.httpMethod = "POST"
        request.addValue(SlideMenuController.getToken(), forHTTPHeaderField: "auth")
        userGroup.enter()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                userGroup.leave()
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode) in getting users")
                print("response = \(String(describing: response))")
                userGroup.leave()
                return
            }
            
            
            let parsedData = ChatController.dataToJSON(data)
            CacheCalendar(parsedData.rawString()!)
            
            events = parseJSONToEvents(parsedData)
            
            userGroup.leave()
        }
        task.resume()
        userGroup.wait()
        DispatchQueue.main.async {
            if events.isEmpty{
                events = LoadCalendarCache()
            }
            completion(events)
        }
    }
    
    static func parseJSONToEvents(_ parsedData: JSON) -> [Event]{
        var array = [Event]()
        
        for json in parsedData.array! {
            let title = json["title"].string!
            let startDate_s:String = json["start"].string!
            let startDate:Date = ChatController.convertFromJSONDate(startDate_s)
            let endDate_s:String? = json["end"].string
            var endDate:Date? = nil
            if(endDate_s != nil){
                endDate = ChatController.convertFromJSONDate(endDate_s!)
            }
            let location = json["location"].string
            let description = json["description"].string
            
            array.append(Event(title, startDate, endDate, location, description))
        }
        
        return array
    }
    
    static func LoadCalendarCache() -> [Event]{
        let calCacheString = UserDefaults.standard.value(forKey: AppDelegate.CACHE_CALENDAR)! as! String;
        let parsedJson = JSON.init(parseJSON: calCacheString)
        
        return DateController.parseJSONToEvents(parsedJson)
    }
    
    static func CacheCalendar(_ stringEncoding: String){
        UserDefaults.standard.set(stringEncoding, forKey: AppDelegate.CACHE_CALENDAR)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

