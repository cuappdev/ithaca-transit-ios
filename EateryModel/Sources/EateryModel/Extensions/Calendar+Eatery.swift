//
//  Calendar+Eatery.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import Foundation

public extension Calendar {

    static let eatery: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York") ?? Calendar.current.timeZone
        return calendar
    }()

}
