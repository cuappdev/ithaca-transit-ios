//
//  Direction.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

protocol Direction {
    var departureTime: Date {get set}
    var departurePlace: String {get set}
    var departureDescription: String {get} //e.g. "Walk to Statler", "Board at Statler", "Debark at Ithaca Commons"
}

/* To get string version of Bound
  * let inbound: String = Bound.inbound.rawValue  //"inbound"
  * let outbound: String = Bound.inbound.rawValue //"outbound"
*/
enum Bound: String{
    case inbound, outbound
}

class BoardDirection: Direction {
    
    var routeNumber: Int
    var bound: Bound
    var stops: [String]
    
    var departureTime: Date
    var departurePlace: String
    var departureDescription: String {
        return "Board at \(departurePlace)"
    }
    
    var arrivalTime: Date
    var arrivalPlace: String
    var arrivalDescription: String {
        return "Debark at \(arrivalPlace)"
    }
    
    //NSELF: REMOVE FROM EXAMPLE
    /*To extract travelTime's times in day, hour, and minute units:
     * let days: Int = travelTime.day
     * let hours: Int = travelTime.hour
     * let minutes: Int = travelTime.minute
     */
    var travelTime: DateComponents {
        return Time.dateComponents(from: departureTime, to: arrivalTime)

    }
    
    init(routeNumber: Int, bound: Bound, stops: [String] = [], departureTime: Date, departurePlace: String, arrivalTime: Date, arrivalPlace: String) {
        self.routeNumber = routeNumber
        self.bound = bound
        self.stops = stops
        self.departureTime = departureTime
        self.departurePlace = departurePlace
        self.arrivalTime = arrivalTime
        self.arrivalPlace = arrivalPlace
    }

}

class WalkDirection: Direction {
    
    var departureTime: Date
    var departurePlace: String
    var departureDescription: String {
        return "Walk to \(departurePlace)"
    }
    var travelDistance: Double
    
    
    init(departureTime: Date, departurePlace: String, travelDistance: Double) {
        self.departureTime = departureTime
        self.departurePlace = departurePlace
        self.travelDistance = travelDistance
    }
}
