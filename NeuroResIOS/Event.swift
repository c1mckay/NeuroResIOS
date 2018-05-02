//
//  Event.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 4/30/18.
//  Copyright © 2018 Charles McKay. All rights reserved.
//

import Foundation
class Event{
    
    var _title: String
    var _start: Date
    var _end: Date?
    var _location: String?
    var _description: String?
    init(_ title: String, _ startTime: Date, _ endTime: Date?, _ location: String?, _ description: String?){
        _title = title
        _start = startTime
        _end = endTime
        _location = location
        _description = description
    }
    
    func getDescription() -> String{
        if(_description == nil){
            return "-No Description-"
        }else{
            return _description!
        }
    }
    
    static func getTime(_ d: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        let ret = formatter.string(from: d)
        
        return ret.replacingOccurrences(of: "M", with: "").lowercased()
    }
    
    func getLongTimeText() -> String{
        if(_end == nil){
            return "All day"
        }
        if(DateController.isSameDay(_start, _end!)){
            return Event.getTime(_start) + "-" + Event.getTime(_end!)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from:_start) + " " + Event.getTime(_start) + " - " + formatter.string(from:_end!) + " " + Event.getTime(_end!)
    }
    
    func getShortTimeText(_ displayDate: Date?) -> String{
        if(_end == nil){
            return "All day"
        }
        if(displayDate == nil){
            return ""
        }
        if(DateController.isSameDay(displayDate!, _start)){
            return Event.getTime(_start)
        }else if(DateController.isSameDay(displayDate!, _end!)){
            return "- " + Event.getTime(_end!)
        }else{
            return "All Day"
        }
    }
    
    func contains(_ date: Date) -> Bool{
        if(DateController.isSameDay(date, _start)){
            return true;
        }
        if(_end == nil){
            return false
        }
        var comp = DateComponents()
        comp.day = 0
        var futureDate = Calendar.current.date(byAdding: comp, to: _start)!
        comp.day = 1
        while(!DateController.isSameDay(_end!, futureDate)){
            futureDate = Calendar.current.date(byAdding: comp, to: futureDate)!
            if(DateController.isSameDay(futureDate, date)){
                return true
            }
        }
        return false
    }
}
