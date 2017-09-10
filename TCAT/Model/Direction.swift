//
//  Direction.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

/* To get string version of Bound
 * let inbound: String = Bound.inbound.rawValue  // "inbound"
 * let outbound: String = Bound.inbound.rawValue // "outbound"
 */
enum Bound: String {
    case inbound, outbound
}

enum DirectionType: String {
    case walk, depart, arrive
}

class Direction: NSObject {
    
    var directionType: DirectionType
    
    var locationName: String
    
    var startLocation: CLLocationCoordinate2D
    var endLocation: CLLocationCoordinate2D
    
    var startTime: Date
    var endTime: Date
    
    // MARK: Special Depart Direction
    
    var busStops: [String] = []
    var routeNumber: Int = 0
    
    init(directionType: DirectionType,
         locationName: String,
         startLocation: CLLocationCoordinate2D,
         endLocation: CLLocationCoordinate2D,
         startTime: Date,
         endTime: Date,
         busStops: [String] = [],
         routeNumber: Int = 0) {
        
        self.directionType = directionType
        self.locationName = locationName
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startTime = startTime
        self.endTime = endTime
        self.busStops = busStops
        self.routeNumber = routeNumber
        
    }
    
    // MARK: Descriptions / Functions
    
    var travelTime: DateComponents {
        return Time.dateComponents(from: startTime, to: endTime)
    }
    
    // TODO: Implement
    var travelDistance: Double {
        return 0
    }
    
    var locationNameDescription: String {
        switch directionType {
            
        case .depart:
            return "at \(locationName)"
            
        case .arrive:
            return "Debark at \(locationName)"
            
        case .walk:
            return "Walk to \(locationName)"
            
        }
    }
    
    func timeDescription(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
}
