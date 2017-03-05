//
//  Route.swift
//  TCAT
//
//  Description: 
//      Data model to represent both route options screen (Monica) and route detail screen (Matt)
//
//  Note:
//      - mainStops is for route options screen (Monica) and directions is for route detail screen (Matt)
//      - departureTime and arrivalTime are for the entire route, while each direction has their own departure (and possibly arrival time)
//
//          Example: (One Route Stop Details screen)
//Route:
//    departureTime = 7:21 PM
//    arrivalTime = 7:39 PM
//    timeUntilDeparture = 5 min
//    directions = [WalkDirection1, BoardDirection, WalkDirection2]
//    mainStops = ["Statler Hall", "Angry Mom Records"]
//    mainStopsNums = [32, 0]
//
//WalkDirection1:
//    departureTime = 7:21 PM
//    departurePlace = "Statler Hall"
//    departureDescription = "Walk to Statler Hall"
//    travelDistance = 0.2
//
//BoardDirection:
//    routeNumber = 32
//    bound = inbound
//    stops = ["Bus Stop Name", "Bus Stop Name", "Bus Stop Name"]
//    departureTime = 7:24 PM
//    departurePlace = "Statler Hall"
//    arrivalTime = 7:36 PM
//    arrivalPlace = "Ithaca Commons"
//    arrivalDescription = "Debark at Ithaca Commons"
//    travelTime = 12 min
//
//WalkDirection2:
//    departureTime = 7:39 PM
//    departurePlace = "Angry Mom Records"
//    departureDescription = "Walk to Angry Mom Records"
//    travelDistance = 0.2
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class Route: NSObject {
    
    var departureTime: Date
    var arrivalTime: Date
    
    /*To extract timeUntilDeparture's times in day, hour, and minute units:
     * let days: Int = timeUntilDeparture.day
     * let hours: Int = timeUntilDeparture.hour
     * let minutes: Int = timeUntilDeparture.minute
     */
    var timeUntilDeparture: DateComponents {
        let now = Date() //curent date
        return Time.dateComponents(from: now, to: departureTime)
    }
    
    var directions: [Direction]
    var mainStops: [String]
    var mainStopsNums: [Int] //-1 for pins
    //N2SELF: possible change this to walkDistance??
    var travelDistance: Double //of first stop
    
    init(departureTime: Date, arrivalTime: Date, directions: [Direction], mainStops: [String], mainStopsNums: [Int], travelDistance: Double) {
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.directions = directions
        self.mainStops = mainStops
        self.mainStopsNums = mainStopsNums
        self.travelDistance = travelDistance
    }
}
