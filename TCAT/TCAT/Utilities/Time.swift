//
//  Time.swift
//  TCAT
//
//  Created by Monica Ong on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation

class Time{
    
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
    
    /*Takes time string formatted in "h:mm a" and returns today's date with that time
     * Throws error if string not formatted in "h:mm a"
     */
    static func date(from string: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.date(from: string)!
        
    }
}
