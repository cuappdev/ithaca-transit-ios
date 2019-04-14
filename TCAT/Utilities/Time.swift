//
//  Time.swift
//  TCAT
//
//  Created by Monica Ong on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
import Foundation

class Time {

    /// Takes date and return full date formatted in "EEEE, MMMM d, yyyy at h:mm a""
    static func dateString(from date: Date) -> String {
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
    static func timeString(from startTime: Date, to endTime: Date) -> String {

        let time = dateComponents(from: startTime, to: endTime)
        var timeStr = ""

        var minutes: Int = time.minute!
        var hours: Int = time.hour!
        var days: Int = time.day!

        if minutes > 0 {
            if minutes >= 60 { hours += 1 }
            minutes = minutes % 60
            timeStr = "\(minutes % 60) min"
        }

        if hours > 0 {
            if hours >= 24 { days += 1 }
            hours = hours % 24
            timeStr = "\(hours) hr " + timeStr
        }

        if days > 0 {
            timeStr = "\(time.day!) d " + timeStr
        }

        if timeStr.isEmpty {
            return "0 min"
        }

        return timeStr.trimmingCharacters(in: .whitespacesAndNewlines)

    }

    /// Check whether 2 dates are equal (to the minute precision)
    static func compare(date1: Date, date2: Date) -> ComparisonResult {
        return Calendar.current.compare(date1, to: date2, toGranularity: .minute)
    }

    /// Calculates time bt 2 dates, returns DateComponents
    static func dateComponents(from startTime: Date, to endTime: Date) -> DateComponents {
        return Calendar.current.dateComponents([.hour, .minute, .day], from: truncateSeconds(from: startTime), to: truncateSeconds(from: endTime))
    }

    /// Calculates dateComponenets for a single date
    static func dateComponents(from date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    }

    static func truncateSeconds(from date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        return calendar.date(from: components)!
    }

    /// Takes time string formatted in "h:mm a" and returns today's date with that time
    static func date(fromTime string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: string)
        var dateComponents = Time.dateComponents(from: date!)

        // Modify date to have today's day, month & year
        var todaysDateComponents = Time.dateComponents(from: Date())
        dateComponents.year = todaysDateComponents.year
        dateComponents.month = todaysDateComponents.month
        dateComponents.day = todaysDateComponents.day

        return Calendar.current.date(from: dateComponents)!
    }

}
