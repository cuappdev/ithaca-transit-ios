//
//  Day.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

// A day, specifically in New York timezone
public struct Day: Codable, Hashable {

    public let year: Int

    public let month: Int

    public let day: Int

    public init(date: Date = Date()) {
        let components = Calendar.eatery.dateComponents([.year, .month, .day], from: date)
        self.year = components.year ?? 0
        self.month = components.month ?? 0
        self.day = components.day ?? 0
    }

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init?(string: String) {
        let components = string.split(separator: "-", maxSplits: 2).map(String.init).map(Int.init)
        guard components.count == 3,
              let year = components[0],
              let month = components[1],
              let day = components[2]
        else {
            return nil
        }

        self.year = year
        self.month = month
        self.day = day
    }

    public func date(hour: Int? = nil, minute: Int? = nil) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)

        guard let date = Calendar.eatery.date(from: components) else {
            logger.error("\(#function): could not form date from components \(components)")
            return Date()
        }

        return date
    }
    
    public func startOfWeek() -> Day {
        let components = DateComponents(weekday: 0)

        guard let date = Calendar.eatery.nextDate(
            after: date(),
            matching: components,
            matchingPolicy: .nextTime,
            direction: .backward
        ) else {
            logger.error("\(#function): could not find start of week for \(self)")
            return self
        }

        return Day(date: date)
    }

    public func weekday() -> Int {
        Calendar.eatery.component(.weekday, from: date())
    }

    public func toWeekdayString() -> String {
        switch self.weekday() {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return ""
        }
    }

}

extension Day: Strideable {

    public func advanced(by n: Int) -> Day {
        let currentDate = date()

        guard let date = Calendar.eatery.date(byAdding: .day, value: n, to: currentDate) else {
            logger.error("\(#function): could not add \(n) days to \(currentDate)")
            return self
        }

        return Day(date: date)
    }

    public func distance(to other: Day) -> Int {
        if let day = Calendar.eatery.dateComponents([.day], from: date(), to: other.date()).day {
            return day
        } else {
            logger.error("\(#function): unable to compute distance between \(date()) and \(other.date())")
            return 0
        }
    }

}

extension Day: RawRepresentable {

    public init?(rawValue: String) {
        self.init(string: rawValue)
    }

    public var rawValue: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

}
