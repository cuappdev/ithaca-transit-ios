//
//  EateryStatus.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

public enum EateryStatus {

    public static func index(_ events: [EateryEvent], filter isIncluded: (EateryEvent) -> Bool, min isLessThan: (EateryEvent, EateryEvent) -> Bool) -> Int? {
        events.enumerated().filter {
            isIncluded($0.element)
        }.min {
            isLessThan($0.element, $1.element)
        }?.offset
    }

    public static func indexOfCurrentEvent(_ events: [EateryEvent], date: Date = Date()) -> Int? {
        events.firstIndex { event in
            event.startDate <= date && date <= event.endDate
        }
    }

    public static func currentEvent(_ events: [EateryEvent], date: Date = Date()) -> EateryEvent? {
        if let index = indexOfCurrentEvent(events, date: date) {
            return events[index]
        } else {
            return nil
        }
    }

    public static func indexOfNextEvent(_ events: [EateryEvent], date: Date = Date()) -> Int? {
        index(events) { event in
            date <= event.startDate
        } min: { lhs, rhs in
            lhs.startDate < rhs.startDate
        }
    }

    public static func nextEvent(_ events: [EateryEvent], date: Date = Date()) -> EateryEvent? {
        if let index = indexOfNextEvent(events, date: date) {
            return events[index]
        } else {
            return nil
        }
    }

    case closed(EateryEvent)

    case closingSoon(EateryEvent)

    case open(EateryEvent)

    case openingSoon(EateryEvent)

    case closeUntilUnknown

    public init(_ events: [EateryEvent], date: Date = Date()) {
        let timestamp: Double = date.timeIntervalSince1970

        if let event = EateryStatus.currentEvent(events, date: date) {
            // The eatery is open. Is it closing soon?
            let timeUntilClose = Double(event.end) - timestamp

            if timeUntilClose <= 60 * 60 {
                self = .closingSoon(event)
            } else {
                self = .open(event)
            }

        } else if let event = EateryStatus.nextEvent(events, date: date) {
            // The eatery is closed. Is it opening soon?
            let timeUntilOpen = Double(event.start) - timestamp

            if timeUntilOpen <= 60 * 60 {
                self = .openingSoon(event)
            } else {
                self = .closed(event)
            }

        } else {
            self = .closeUntilUnknown

        }
    }

    public var isOpen: Bool {
        switch self {
        case .open, .closingSoon: return true
        case .closed, .openingSoon, .closeUntilUnknown: return false
        }
    }

}
