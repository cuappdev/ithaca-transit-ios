//
//  Event.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public struct Event: Codable, Hashable {

    public var canonicalDay: Day

    public var description: String?

    public var endTimestamp: TimeInterval

    public var menu: Menu?

    public var startTimestamp: TimeInterval

    public init(
        canonicalDay: Day,
        description: String? = nil,
        endTimestamp: TimeInterval,
        menu: Menu? = nil,
        startTimestamp: TimeInterval
    ) {
        self.canonicalDay = canonicalDay
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.description = description
        self.menu = menu
    }

}

extension Event {

    public var endDate: Date {
        Date(timeIntervalSince1970: endTimestamp)
    }

    public var startDate: Date {
        Date(timeIntervalSince1970: startTimestamp)
    }

}
