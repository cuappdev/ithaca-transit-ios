//
//  ServiceAlert.swift
//  TCAT
//
//  Created by Omar Rasheed on 4/19/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

struct ServiceAlert: Codable {
    var channelMessages: [ChannelMessage]
    var daysOfWeek: String
    var fromDate: String
    var fromTime: String
    var id: Int
    var message: String
    var priority: Int
    var routes: [Int]
    var signs: [Int]
    var toDate: String
    var toTime: String
}

struct ChannelMessage: Codable {
    var ChannelId: Int
    var message: String
}
