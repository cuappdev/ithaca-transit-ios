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

class Direction: NSObject {

    var type: DirectionType

    var locationName: String

    var startLocation: CLLocation
    var endLocation: CLLocation

    var startTime: Date
    var endTime: Date

    var path: [CLLocationCoordinate2D]

    var routeNumber: Int
    var busStops: [String]

    init(type: DirectionType,
         locationName: String,
         startLocation: CLLocation,
         endLocation: CLLocation,
         startTime: Date,
         endTime: Date,
         path: [CLLocationCoordinate2D] = [],
         busStops: [String] = [],
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
    }

    convenience init(name: String) {

        let blankLocation = CLLocation()
        let blankTime = Date()

        self.init(
            type: .arrive,
            locationName: name,
            startLocation: blankLocation,
            endLocation: blankLocation,
            startTime: blankTime,
            endTime: blankTime,
            path: []
        )

    }

    convenience init(from json: JSON, baseTime: Double) {
        

        
        // Return [String] of name of timed bus stops
        func jsonToStopArray() -> [String] {
            return json["busPath"]["path"]["timedStops"].arrayValue.flatMap {
                $0["name"].stringValue
            }
        }
        
        // Precondition: passed in json with 'start' or 'end'
        func locationJSON(from json: JSON) -> CLLocation {
            return CLLocation(latitude: json["location"]["latitude"].doubleValue,
                              longitude: json["location"]["longitude"].doubleValue)
        }
        
        let pathHelper = PathHelper()
        let type: DirectionType = json["busPath"] != JSON.null ? .depart : .walk
        let startLocation = locationJSON(from: json["start"])
        let endLocation = locationJSON(from: json["end"])
        
        self.init(

            type: type,

            locationName: json["\(type == .depart ? "start" : "end")"]["name"].stringValue,

            startLocation: startLocation,

            endLocation: endLocation,

            startTime: Date(timeIntervalSince1970: baseTime + json["startTime"].doubleValue),

            endTime: Date(timeIntervalSince1970: baseTime + json["endTime"].doubleValue),

            path: pathHelper.filterPath(in: json, from: startLocation.coordinate, to: endLocation.coordinate),

            busStops: jsonToStopArray(),

            routeNumber: json["busPath"]["lineNumber"].intValue

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

    static func coordsEqual(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {

        func rnd(_ number: Double, to place: Int = 6) -> Double {
            return round(number * pow(10.0, Double(place))) / pow(10.0, Double(place))
        }

        let result = rnd(rhs.latitude) == rnd(lhs.latitude) && rnd(rhs.longitude) == rnd(lhs.longitude)
        return result

    }
    
 

}
