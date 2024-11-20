//
//  Shared.swift
//  TCAT
//
//  Created by Yana Sang on 12/2/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import Foundation

/// This class is for shared enums between TCAT and the Today Extension.

enum SearchType: String {
    case arriveBy, leaveAt, leaveNow
}

enum DelayState {
    case late(date: Date)
    case onTime(date: Date)
    case noDelay(date: Date)
}
