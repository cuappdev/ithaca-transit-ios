//
//  ServiceAlert.swift
//  TCAT
//
//  Created by Omar Rasheed on 4/19/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

struct ServiceAlert: Codable {
    var id: Int
    var message: String
    var fromDate: String
    var toDate: String
    var fromTime: String
    var toTime: String
    var priority: Int
    var daysOfWeek: String
    var routes: [Int]
    var signs: [Int]
    var channelMessages: [ChannelMessage]

    init(id: Int,
         message: String,
         fromDate: String,
         toDate: String,
         fromTime: String,
         toTime: String,
         priority: Int,
         daysOfWeek: String,
         routes: [Int],
         signs: [Int],
         channelMessages: [ChannelMessage]) {

        self.id = id
        self.message = message
        self.fromDate = fromDate
        self.toDate = toDate
        self.fromTime = fromTime
        self.toTime = toTime
        self.priority = priority
        self.daysOfWeek = daysOfWeek
        self.routes = routes
        self.signs = signs
        self.channelMessages = channelMessages

    }
}

struct ChannelMessage: Codable {
    var ChannelId: Int
    var message: String
}
