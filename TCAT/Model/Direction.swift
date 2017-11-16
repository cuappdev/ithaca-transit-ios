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
import SwiftyJSON

/* To get string version of Bound
 * let inbound: String = Bound.inbound.rawValue  //"inbound"
 * let outbound: String = Bound.inbound.rawValue //"outbound"
 */
enum Bound: String {
    case inbound, outbound
}

enum DirectionType: String {
    case walk, depart, arrive, unknown
}

class Direction: NSObject, NSCopying {

    var type: DirectionType

    var locationName: String

    var startLocation: CLLocation
    var endLocation: CLLocation

    var startTime: Date
    var endTime: Date

    var path: [CLLocationCoordinate2D]

    var routeNumber: Int
    
    var busStops: [String]
    var stopLocations: [CLLocationCoordinate2D]

    required init(type: DirectionType,
         locationName: String,
         startLocation: CLLocation,
         endLocation: CLLocation,
         startTime: Date,
         endTime: Date,
         path: [CLLocationCoordinate2D] = [],
         busStops: [String] = [],
         stopLocations: [CLLocationCoordinate2D] = [],
         routeNumber: Int = 0) {

        self.type = type
        self.locationName = locationName
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startTime = startTime
        self.path = path
        self.endTime = endTime
        self.routeNumber = routeNumber
        self.busStops = busStops
        self.stopLocations = stopLocations
        
    }

    convenience init(locationName: String) {

        let blankLocation = CLLocation()
        let blankTime = Date()

        self.init(
            type: .arrive,
            locationName: locationName,
            startLocation: blankLocation,
            endLocation: blankLocation,
            startTime: blankTime,
            endTime: blankTime
        )

    }

    convenience init(from json: JSON, baseTime: Double) {
        
        // Return [String] filed with names of bus stops
        func jsonToStopNames() -> [String] {
            return json["busPath"]["path"]["timedStops"].arrayValue.flatMap {
                $0["stop"]["name"].stringValue
            }
        }
        
        func jsonToStopLocations(filterWith stops: [String] = []) -> [CLLocationCoordinate2D] {
            
            var jsonArray = json["busPath"]["path"]["timedStops"].arrayValue
            
            if !stops.isEmpty {
                jsonArray = jsonArray.filter {
                    stops.contains($0["stop"]["name"].stringValue)
                }
            }
            
            return jsonArray.flatMap {
                locationJSON(from: $0["stop"]).coordinate
            }

        }
        
        // Precondition: passed in json with 'start' or 'end'
        func locationJSON(from json: JSON) -> CLLocation {
            return CLLocation(latitude: json["location"]["latitude"].doubleValue,
                              longitude: json["location"]["longitude"].doubleValue)
        }
        
        let type: DirectionType = json["busPath"] != JSON.null ? .depart : .walk
        let startLocation = locationJSON(from: json["start"])
        let endLocation = locationJSON(from: json["end"])
        let filteredPath = PathHelper.shared.filterPath(in: json, from: startLocation.coordinate, to: endLocation.coordinate)
        let filteredStops = PathHelper.shared.filterStops(in: jsonToStopNames(), along: filteredPath)
        
        self.init(

            type: type,

            locationName: json["\(type == .depart ? "start" : "end")"]["name"].stringValue,

            startLocation: startLocation,

            endLocation: endLocation,

            startTime: Date(timeIntervalSince1970: baseTime + json["startTime"].doubleValue),

            endTime: Date(timeIntervalSince1970: baseTime + json["endTime"].doubleValue),

            path: filteredPath,

            busStops: filteredStops,
            
            stopLocations: jsonToStopLocations(filterWith: filteredStops),
            

            routeNumber: json["busPath"]["lineNumber"].intValue

        )
        


    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        return Swift.type(of: self).init(
            type: type,
            locationName: locationName,
            startLocation: startLocation,
            endLocation: endLocation,
            startTime: startTime,
            endTime: endTime,
            path: path
        )
        
    }


    // MARK: Descriptions / Functions
    
    /// Distance between start and end locations in miles
    var travelDistance: Double {
        let metersInMile = 1609.34
        var distance =  startLocation.distance(from: endLocation) / metersInMile
        let numberOfPlaces = distance >= 10 ? 0 : 1
        return distance.roundToPlaces(places: numberOfPlaces)
    }

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
    
    override var debugDescription: String {
        return """
            type: \(self.type)\n
            startTime: \(self.startTime)\n
            endTime: \(self.endTime)\n
            startLocation: \(self.startLocation)\n
            endLocation: \(self.endLocation)\n
            busStops: \(self.busStops)\n
            travelDistance: \(self.travelDistance)\n
            locationNameDescription: \(self.locationNameDescription)\n
            locationName: \(self.locationName)\n
            stops: \(self.busStops)
        """
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
