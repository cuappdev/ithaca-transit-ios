//
//  Time.swift
//  TCAT
//
//  Created by Monica Ong on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation

class Time{
    
    /// Takes date and return full date formatted in "EEEE, MMMM d, yyyy at h:mm a""
    static func dateString(from date: Date)-> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Takes date and return time formatted in "h:mm a"
    static func timeString(from time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    /// Returns time between 2 dates formatted in "# d  # hr # min"
    static func timeString(from startTime: Date, to endTime: Date) -> String{
        let time = dateComponents(from: startTime, to: endTime)
        var timeStr = ""
        if time.day! > 0 {
            timeStr += "\(time.day!) d "
        }
        
        if time.hour! > 0 {
            timeStr += "\(time.hour!) hr "
        }
        
        if time.minute! > 0 {
            timeStr += "\(time.minute!) min"
        }
        
        if timeStr.isEmpty {
            timeStr = "0 min"
        }
        
        return timeStr
    }
    
    /// Check whether 2 dates are equal (to the minute precision)
    static func equalToMinute(date1: Date, date2: Date) -> Bool {
        let dateComp1 = Calendar.current.dateComponents([.year,.month,.day, .hour, .minute], from: date1)
        let dateComp2 = Calendar.current.dateComponents([.year,.month,.day, .hour, .minute], from: date2)
        
        if dateComp1.year != dateComp2.year {
            return false
        }
        
        if dateComp1.month != dateComp2.month {
            return false
        }
        
        if dateComp1.day != dateComp2.day {
            return false
        }
        
        if dateComp1.hour != dateComp2.hour {
            return false
        }
        
        if dateComp1.minute != dateComp2.minute {
            return false
        }
        
        return true
    }
    
    /// Calculates time bt 2 dates, returns DateComponents
    static func dateComponents(from startTime: Date, to endTime: Date) -> DateComponents{
        return Calendar.current.dateComponents([.hour, .minute, .day], from: startTime, to: endTime)
    }
    
    /// Calculates dateComponenets for a single date
    static func dateComponents(from date: Date) -> DateComponents{
        return Calendar.current.dateComponents([.year,.month,.day, .hour, .minute], from: date)
    }
    
    /// Takes time string formatted in "h:mm a" and returns today's date with that time
    static func date(fromTime string: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: string)
        var dateComponents = Time.dateComponents(from: date!)
        
        //Modify date to have today's day, month & year
        var todaysDateComponents = Time.dateComponents(from: Date())
        dateComponents.year = todaysDateComponents.year
        dateComponents.month = todaysDateComponents.month
        dateComponents.day = todaysDateComponents.day
        
        return Calendar.current.date(from: dateComponents)!
    }
}
