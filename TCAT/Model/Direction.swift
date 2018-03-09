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

/// An enum for the type of direction
enum DirectionType: String {
    
    /// Directions that involving walking
    case walk
    /// Directions where the user gets on the bus
    case depart
    /// Direction where the user gets off the bus
    case arrive
    /// Direction where transfer is involved, but user stays on bus
    case transfer

}

class Direction: NSObject, NSCopying {

    /// The type of the direction.
    var type: DirectionType

    /**
     General description for the direction.
     
     - walk: The description of the place / location the user is walking to
     - depart: The name of the bus stop where the bus is departing from
     - arrive: The name of the bus stop where the user gets off the bus
     */
    var name: String

    /** The starting location object associated with the direction
        If this is a bus stop, includes stopID as id.
     */
    var startLocation: LocationObject
    
    /** The ending location object associated with the direction
        If this is a bus stop, includes stopID as id.
    */
    var endLocation: LocationObject

    /// The starting time (UTC) associated with the direction. Format: `"yyyy-MM-dd'T'HH:mm:ssZZZZ"`
    var startTime: Date
    
    /// The starting time (UTC) associated with the direction Format: `"yyyy-MM-dd'T'HH:mm:ssZZZZ"`
    var endTime: Date

    /// The corresponding path of the direction
    var path: [CLLocationCoordinate2D]
    
    /// The total distance of the direction, in meters.
    var travelDistance: Double = 0

    /// The number representing the bus route.
    var routeNumber: Int = 0
    
    /// An array of bus stop locations on the bus route, excluding the departure and arrival stop. Empty if `type != .depart`.
    var stops: [LocationObject] = []
    
    /// Whether the user should stay on this direction's bus for an upcoming transfer.
    var stayOnBusForTransfer: Bool = false
    
    /// The unique identifier for the specific bus related to the direction.
    var tripIDs: [String]?
    
    // MARK: Initalizers

    required init (
        type: DirectionType,
        name: String,
        startLocation: LocationObject,
        endLocation: LocationObject,
        startTime: Date,
        endTime: Date,
        path: [CLLocationCoordinate2D],
        travelDistance: Double,
        routeNumber: Int,
        stops: [LocationObject],
        stayOnBusForTransfer: Bool,
        tripIDs: [String]?
    ) {
        self.type = type
        self.name = name
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startTime = startTime
        self.endTime = endTime
        self.path = path
        self.travelDistance = travelDistance
        self.routeNumber = routeNumber
        self.stops = stops
        self.stayOnBusForTransfer = stayOnBusForTransfer
        self.tripIDs = tripIDs
    }

    convenience init(name: String? = nil) {

        let blankLocation = LocationObject.blank
        let blankTime = Date()

        self.init(
            type: .arrive,
            name: name ?? "",
            startLocation: blankLocation,
            endLocation: blankLocation,
            startTime: blankTime,
            endTime: blankTime,
            path: [],
            travelDistance: 0,
            routeNumber: 0,
            stops: [],
            stayOnBusForTransfer: false,
            tripIDs: []
        )

    }

    convenience init(from json: JSON) {
        
        // print("Direction JSON:", json)
        
        self.init()
        
        name = json["name"].stringValue
        type = json["type"].stringValue.lowercased() == "depart" ? .depart : .walk
        startTime = json["startTime"].parseDate()
        endTime = json["endTime"].parseDate()
        startLocation = json["startLocation"].parseLocationObject()
        endLocation = json["endLocation"].parseLocationObject()
        path = json["path"].arrayValue.map { $0.parseCoordinates() }
        travelDistance = json["distance"].doubleValue
        routeNumber = json["routeNumber"].int ?? 0
        stops = json["stops"].arrayValue.map { $0.parseLocationObject() }
        stayOnBusForTransfer = json["stayOnBusForTransfer"].boolValue
        tripIDs = json["tripID"].arrayValue.map { $0.stringValue }
        
        // If depart direction, use bus stop locations (with id) for start and end
        if type == .depart, let start = stops.first, let end = stops.last {
            startLocation = start
            endLocation = end
        }
        
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Swift.type(of: self).init(
            type: type,
            name: name,
            startLocation: startLocation,
            endLocation: endLocation,
            startTime: startTime,
            endTime: endTime,
            path: path,
            travelDistance: travelDistance,
            routeNumber: routeNumber,
            stops: stops,
            stayOnBusForTransfer: stayOnBusForTransfer,
            tripIDs: tripIDs
        )
    }


    // MARK: Descriptions

    /// Returns custom description for locationName based on DirectionType
    var locationNameDescription: String {
        switch type {

        case .depart:
            return "at \(name)"

        case .arrive:
            return "Debark at \(name)"

        case .walk:
            return "Walk to \(name)"
            
        case .transfer:
            return "at \(name). Stay on board."

        }
    }
    
    override var debugDescription: String {
        return """
        {
            type: \(type),
            name: \(name),
            startTime: \(startTime),
            endTime: \(endTime),
            startLocation: \(startLocation),
            endLocation: \(endLocation),
            stops: \(stops),
            distance: \(travelDistance),
            locationNameDescription: \(locationNameDescription),
            stops: \(stops)
        }
        """
    }
    
    // MARK: Complex Variables & Functions

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
