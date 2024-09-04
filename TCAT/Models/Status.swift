//
//  Status.swift
//  Uplift
//
//  Created by Vin Bui on 12/24/23.
//  Copyright © 2023 Cornell AppDev. All rights reserved.
//

import Foundation

/// The status of the Gym or Facility.
enum Status: Hashable, Comparable {

    /// Currently closed where `openTime` is the `Date` in which it will open next.
    case closed(openTime: Date)

    /// Currently open where `closeTime` is the `Date` in which it will begin closing.
    case open(closeTime: Date)

    /// Open status is less than closed status.
    static func < (lhs: Status, rhs: Status) -> Bool {
        var lhsVal: Int
        var rhsVal: Int

        switch lhs {
        case .closed:
            lhsVal = 1
        case .open:
            lhsVal = 0
        }

        switch rhs {
        case .closed:
            rhsVal = 1
        case .open:
            rhsVal = 0
        }

        return lhsVal < rhsVal
    }

}
