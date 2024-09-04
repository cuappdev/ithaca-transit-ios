//
//  OpenHours.swift
//  Uplift
//
//  Created by Vin Bui on 12/24/23.
//  Copyright © 2023 Cornell AppDev. All rights reserved.
//

import Foundation

/// Model representing a facility's open hours.
struct OpenHours: Comparable {

    // MARK: - Properties

    /// The closing time of these hours.
    let endTime: Date

    /// Whether the pool hours is shallow waters only.
    let isShallow: Bool?

    /// Whether these hours are special (non-regular).
    let isSpecial: Bool

    /// Whether the pool hours is women only.
    let isWomen: Bool?

    /// The opening time of these hours.
    let startTime: Date

    // MARK: - Functions

    /// Initializes this object given an `OpenHoursFields` type.
    init(from openHours: UpliftAPI.OpenHoursFields) {
        self.endTime = Date(timeIntervalSince1970: TimeInterval(openHours.endTime))
        self.isShallow = openHours.isShallow
        self.isSpecial = openHours.isSpecial
        self.isWomen = openHours.isWomen
        self.startTime = Date(timeIntervalSince1970: TimeInterval(openHours.startTime))
    }

    /// Returns `true` if `lhs` has an earlier start time than `rhs`.
    static func < (lhs: OpenHours, rhs: OpenHours) -> Bool {
        lhs.startTime < rhs.startTime
    }

}
