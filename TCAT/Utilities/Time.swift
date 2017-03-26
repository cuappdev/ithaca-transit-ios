//
//  Time.swift
//  TCAT
//
//  Created by Monica Ong on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation

class Time{
    
    /*Takes date and return full date formatted in "EEEE, MMMM d, yyyy at h:mm a""
     */
    static func fullString(from date: Date)-> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /*Takes date and return time formatted in "h:mm a"
     */
    static func string(from time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    /*Calculates time bt 2 dates, returns DateComponents
     */
    static func dateComponents(from startTime: Date, to endTime: Date) -> DateComponents{
        return Calendar.current.dateComponents([.hour, .minute, .day], from: startTime, to: endTime)
    }
    
    /*Calculates dateComponenets for a single date
     */
    static func dateComponents(from date: Date) -> DateComponents{
        return Calendar.current.dateComponents([.year,.month,.day, .hour, .minute], from: date)
    }
    
    /*Takes time string formatted in "h:mm a" and returns today's date with that time
     * Throws error if string not formatted in "h:mm a"
     */
    static func date(from string: String) -> Date{
        //Get date
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
