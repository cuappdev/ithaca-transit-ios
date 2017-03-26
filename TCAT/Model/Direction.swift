//
//  Direction.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation

protocol Direction {
    var time: Date {get set}
    var place: String {get set}
    var location: CLLocation {get set}
    var placeDescription: String {get} //e.g. "Walk to Statler", "Board at Statler", "Debark at Ithaca Commons"
    var timeDescription: String {get} // "e.g. 7:21 PM"
}

/* To get string version of Bound
 * let inbound: String = Bound.inbound.rawValue  //"inbound"
 * let outbound: String = Bound.inbound.rawValue //"outbound"
 */
enum Bound: String {
    case inbound, outbound
}

struct DepartDirection: Direction {
    
    var time: Date
    var place: String
    var placeDescription: String {
        return "at \(place)"
    }
    var timeDescription: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    var location: CLLocation
    
    var routeNumber: Int
    var bound: Bound
    var stops: [String]
    var arrivalTime: Date
    
    /*To extract travelTime's times in day, hour, and minute units:
     * let days: Int = travelTime.day
     * let hours: Int = travelTime.hour
     * let minutes: Int = travelTime.minute
     */
    var travelTime: DateComponents {
        return Time.dateComponents(from: time, to: arrivalTime)
    }
    
    init(time: Date, place: String, location: CLLocation, routeNumber: Int, bound: Bound, stops: [String] = [],  arrivalTime: Date) {
        self.time = time
        self.place = place
        self.location = location
        self.routeNumber = routeNumber
        self.bound = bound
        self.stops = stops
        self.arrivalTime = arrivalTime
    }
    
}

struct ArriveDirection: Direction {
    
    var time: Date
    var place: String
    var placeDescription: String {
        return "Debark at \(place)"
    }
    var timeDescription: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    var location: CLLocation
    
    init(time: Date, place: String, location: CLLocation) {
        self.time = time
        self.place = place
        self.location = location
    }
    
}

struct WalkDirection: Direction {
    
    var time: Date
    var place: String
    var placeDescription: String {
        return "Walk to \(place)"
    }
    var timeDescription: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    var location: CLLocation
    
    var travelDistance: Double
    
    init(time: Date, place: String, location: CLLocation, travelDistance: Double) {
        self.time = time
        self.place = place
        self.location = location
        self.travelDistance = travelDistance
    }
}
