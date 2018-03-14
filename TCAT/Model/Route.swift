//
//  Route.swift
//  TCAT
//
//  Description:
//      Data model to represent both route options screen (Monica) and route detail screen (Matt)
//
//  Note:
//      - routeSummary is for route options screen (Monica) and directions is for route detail screen (Matt)
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
import UIKit
import TRON
import SwiftyJSON
import CoreLocation
import MapKit

struct Bounds {
    
    /// The minimum latitude value in all of the path's route.
    var minLat: Double
    
    /// The minimum longitude value in all of the path's route.
    var minLong: Double
    
    /// The maximum latitude value in all of the path's route.
    var maxLat: Double
    
    /// The maximum longitude value in all of the path's route.
    var maxLong: Double
    
    init(minLat: Double, minLong: Double, maxLat: Double, maxLong: Double) {
        self.minLat = minLat
        self.minLong = minLong
        self.maxLat = maxLat
        self.maxLong = maxLong
    }
    
}

class Route: NSObject, JSONDecodable {
    
    /// The time a user begins their journey
    var departureTime: Date
    
    /// The time a user arrives at their destination.
    var arrivalTime: Date
    
    /// The amount of time from now until the departure
    var timeUntilDeparture: DateComponents {
        return Time.dateComponents(from: Date(), to: departureTime)
    }
    
    /// The starting coordinates of the route
    var startCoords: CLLocationCoordinate2D
    
    /// The ending coordinates of the route
    var endCoords: CLLocationCoordinate2D
    
    /// The distance between the start and finish location, in miles
    var travelDistance: Double = 0.0
    
    /// The most extreme points of the route
    var boundingBox: Bounds
    
    /// The number of transfers in a route. Defaults to 0
    var numberOfTransfers: Int = 0
    
    /// A list of Direction objects (used for Route Detail)
    var directions: [Direction] = [Direction]()
    
    /** A description of the starting location of the route (e.g. Current Location, Arts Quad)
        Default assumption is Current Location.
     */
    var startName: String
    
    /// A description of the final destination of the route (e.g. Chipotle Mexican Grill, The Shops at Ithaca Mall)
    var endName: String
    
    /// The number of minutes the route will take. Returns 0 in case of error.
    var totalDuration: Int {
        return Time.dateComponents(from: departureTime, to: arrivalTime).minute ?? 0
    }
    
    required init(json: JSON) throws {
        
        departureTime = json["departureTime"].parseDate()
        arrivalTime = json["arrivalTime"].parseDate()
        startCoords = json["startCoords"].parseCoordinates()
        endCoords = json["endCoords"].parseCoordinates()
        startName = json["startName"].stringValue
        endName = json["endName"].stringValue
        boundingBox = json["boundingBox"].parseBounds()
        numberOfTransfers = json["numberOfTransfers"].intValue
        directions = json["directions"].arrayValue.map { Direction(from: $0) }

        // Replace hard-coded destination
        directions.last?.name = endName
        
        super.init()

        // Parse and format directions
        
        /// Variable to keep track of additions to direction list (Arrival Directions)
        var offset = 0
        
        /// True if previous direction indicated next bus is a transfer to stay on
        var isTransfer: Bool = false
        
        for (index, direction) in directions.enumerated() {
            
            if direction.type == .depart {
                
                if !direction.stayOnBusForTransfer {
                    
                    // Create Arrival Direction
                    let arriveDirection = direction.copy() as! Direction
                    arriveDirection.type = .arrive
                    arriveDirection.startTime = arriveDirection.endTime
                    arriveDirection.startLocation = arriveDirection.endLocation
                    arriveDirection.stops = []
                    arriveDirection.name = direction.stops.last?.name ?? "Nil"
                    directions.insert(arriveDirection, at: index + offset + 1)
                    offset += 1
                    
                }
                
                if isTransfer {
                    
                     direction.type = .transfer
                    
                }
                
                isTransfer = direction.stayOnBusForTransfer
                
                // Remove inital bus stop and departure bus stop
                if direction.stops.count >= 2 {
                    direction.stops.removeFirst()
                    direction.stops.removeLast()
                }
                
            }
            
        }
        
        // Calculate travel distance
        calculateTravelDistance(fromDirection: directions)
        
    }
    
    // MARK: Parse JSON
    
    /// Handle route calculation data request.
    static func getRoutes(in json: JSON, from: String?, to: String?,
                          _ completion: @escaping (_ routes: [Route], _ error: NSError?) -> Void) {
        
        if json["success"].boolValue {
            let routes: [Route] = json["data"].arrayValue.map {
                var augmentedJSON = $0
                augmentedJSON["startName"].string = from ?? Constants.Stops.currentLocation
                augmentedJSON["endName"].string = to ?? Constants.Stops.destination
                return try! Route(json: augmentedJSON)
            }
            completion(routes, nil)
        } else {
            let userInfo = ["description" : json["error"].stringValue]
            let error = NSError(domain: "Route Calculation Failure", code: 400, userInfo: userInfo)
            completion([], error)
        }
        
    }
    
    // MARK: Process routes
    
    func isWalkingRoute() -> Bool {
        return directions.reduce(true) { $0 && $1.type == .walk }
    }
    
    func getFirstDepartDirection() -> Direction? {
        return directions.first { $0.type == .depart }
    }
    
    func getLastArriveDirection() -> Direction? {
        return directions.reversed().first { $0.type == .arrive }
    }
    
    func getNumOfWalkLines() -> Int {
        var count = 0
        for (index, direction) in directions.enumerated() {
            if index != directions.count - 1 && direction.type == .walk {
                count += 1
            }
        }
        
        return count
    }
    
    /** Calculate travel distance from location passed in to first route summary object and updates travel distance of route
     */
    func calculateTravelDistance(fromDirection directions: [Direction]) {
        
        // firstRouteOptionsStop = first bus stop in the route
        guard var stop = directions.first else {
            return
        }
        
        // If more than just a walking route that starts with walking
        if !isWalkingRoute() && directions.first?.type == .walk && directions.count > 1 {
            stop = directions[1]
        }
        
        let fromLocation = CLLocation(latitude: startCoords.latitude, longitude: startCoords.longitude)
        var endLocation = CLLocation(latitude: stop.startLocation.latitude, longitude: stop.startLocation.longitude)
        
        if isWalkingRoute() {
            endLocation = CLLocation(latitude: stop.endLocation.latitude, longitude: stop.endLocation.longitude)
        }
        
        travelDistance = fromLocation.distance(from: endLocation)
        
    }
    
    override var debugDescription: String {
        
        let mainDescription = """
            departtureTime: \(self.departureTime)\n
            arrivalTime: \(self.arrivalTime)\n
            startCoords: \(self.startCoords)\n
            endCoords: \(self.endCoords)\n
            startName: \(self.startName)\n
            endName: \(self.endName)\n
            timeUntilDeparture: \(self.timeUntilDeparture)\n
        """
        
        return mainDescription
        
    }
    
    /** Return a one sentence summary of the route, based on the first depart
        or walking direction. Returns "" if no directions.
     */
    var summaryDescription: String {
        
        var description = "To get from \(self.startName) to \(self.endName),"
        
        if description.contains(Constants.Stops.currentLocation) {
            description = "To get to \(self.endName),"
        }
        
        if let direction = directions.first(where: { $0.type == .depart }) {
            
            let number = direction.routeNumber
            let start = direction.startLocation.name
            let end = direction.endLocation.name
            description += " take Route \(number) from \(start) to \(end)."
            
        } else {
            
            // Walking Direction
            guard let direction = directions.first else {
                return ""
            }
            
            let distance = roundedString(direction.travelDistance)
            let start = direction.startLocation.name
            let end = direction.endLocation.name
            description = "Walk \(distance) from \(start) to \(end)."
            
        }
        
        return description
        
    }
    
    /// Number of directions with .depart type
    func numberOfBusRoutes() -> Int {
        return directions.reduce(0) { $0 + ($1.type == .depart ? 1 : 0) }
    }
    
}
