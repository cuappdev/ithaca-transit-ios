//
//  Direction.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

/* To get string version of Bound
 * let inbound: String = Bound.inbound.rawValue  // "inbound"
 * let outbound: String = Bound.inbound.rawValue // "outbound"
 */
enum Bound: String {
    case inbound, outbound
}

enum DirectionType: String {
    case walk, depart, arrive, unknown
}

class Direction: NSObject {
    
    var type: DirectionType
    
    var locationName: String
    
    var startLocation: CLLocation
    var endLocation: CLLocation
    
    var startTime: Date
    var endTime: Date
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

    init(type: DirectionType,
         locationName: String,
         startLocation: CLLocation,
         endLocation: CLLocation,
         startTime: Date,
         endTime: Date,
         busStops: [String] = [],
         routeNumber: Int = 0) {
        
        self.type = type
        self.locationName = locationName
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startTime = startTime
        self.endTime = endTime
        self.busStops = busStops
        self.routeNumber = routeNumber
        self.bound = bound
        self.stops = stops
        self.arrivalTime = arrivalTime
    }

    convenience init(name: String) {
        
        let location = CLLocation()
        let time = Date()
        
        self.init(type: .arrive,
                  locationName: name,
                  startLocation: location,
                  endLocation: location,
                  startTime: time,
                  endTime: time)
        
    }
    
    convenience init(from json: JSON) {
        
        func locationJSON(_ json: JSON) -> CLLocation {
            return CLLocation(latitude: json[0].doubleValue, longitude: json[1].doubleValue)
        }
        
        self.init(
    
            type: DirectionType(rawValue: json["type"].stringValue) ?? .unknown,
            
            locationName: json["locationName"].stringValue,
            
            startLocation: locationJSON(json["startLocation"]),
            
            endLocation: locationJSON(json["endLocation"]),
            
            startTime: Date(timeIntervalSince1970: json["startTime"].doubleValue),
            
            endTime: Date(timeIntervalSince1970: json["endTime"].doubleValue),
            
            busStops: json["busStops"].arrayObject as! [String],
            
            routeNumber: json["routeNumber"].intValue
    
        )
        
    }
    
    // MARK: Descriptions / Functions
    
    /// Returns DateComponents describing difference between start and end time
    var travelTime: DateComponents {
        return Time.dateComponents(from: startTime, to: endTime)
    }
    
    /// Distance between start and end locations in miles
    var travelDistance: Double {
        let metersInMile = 1609.34
        var distance =  startLocation.distance(from: endLocation) / metersInMile
        let numberOfPlaces = distance >= 10 ? 0 : 1
        return distance.roundToPlaces(places: numberOfPlaces)
    }
    var location: CLLocation

    /// Returns custom description for locationName based on DirectionType
    var locationNameDescription: String {
        switch type {
            
        case .depart:
            return "at \(locationName)"
            
        case .arrive:
            return "Debark at \(locationName)"
            
        case .walk:
            return "Walk to \(locationName)"
            
        case .unknown:
            return locationName
            
        }
    }
    
    /// Returns readable start time (e.g. 7:49 PM)
    var startTimeDescription: String {
        return timeDescription(startTime)
    }
    
    /// Returns readable end time (e.g. 7:49 PM)
    var endTimeDescription: String {
        return timeDescription(endTime)
    }
    
    private func timeDescription(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
}
