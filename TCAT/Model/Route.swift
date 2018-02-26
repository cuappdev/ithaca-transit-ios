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

        // Create Arrive Direction after Depart Direction
        for (index, direction) in directions.enumerated() {
            if direction.type == .depart {
                let arriveDirection = direction.copy() as! Direction
                arriveDirection.type = .arrive
                arriveDirection.startTime = arriveDirection.endTime
                arriveDirection.startLocation = arriveDirection.endLocation
                arriveDirection.stops = []
                arriveDirection.name = direction.stops.last?.name ?? "Nil"
                directions.insert(arriveDirection, at: index+1)
            }
        }
        
        // Calculate travel distance
        calculateTravelDistance(fromDirection: directions)
    }
    
    // MARK: Parse JSON
    
    static func getRoutes(from json: JSON, fromDescription: String? = nil, toDescription: String? = nil) -> [Route] {
        return json.arrayValue.map {
            var augmentedJSON = $0
            augmentedJSON["startName"].string = fromDescription ?? "Current Location"
            augmentedJSON["endName"].string = toDescription ?? "your destination"
            return try! Route(json: augmentedJSON)
        }
    }
    
    // MARK: Process raw routes
    
    func isWalkingRoute() -> Bool {
        let isWalkingRoute = directions.reduce(true) { $0 && $1.type == .walk }
        
        return isWalkingRoute
    }
    
    /** Calculate travel distance from location passed in to first route summary object and updates travel distance of route
     */
    func calculateTravelDistance(fromDirection directions: [Direction]) {
        // first route option stop is the first bus stop in the route
        guard let firstRouteOptionsStop = directions.first?.type == .walk ? directions[1] : directions.first else {
            return
        }
        
        let fromLocation = CLLocation(latitude: startCoords.latitude, longitude: startCoords.longitude)
        let endLocation = CLLocation(latitude: firstRouteOptionsStop.startLocation.latitude, longitude: firstRouteOptionsStop.startLocation.longitude)
        
        let numberOfMetersInMile = 1609.34
        let distanceInMeters = fromLocation.distance(from: endLocation)
        let distanceInMiles = distanceInMeters / numberOfMetersInMile
        
        travelDistance = distanceInMiles
    }
    
    override var debugDescription: String {
        
        let mainDescription = """
            departtureTime: \(self.departureTime)\n
            arrivalTime: \(self.arrivalTime)\n
            startCoords: \(self.startCoords)\n
            endCoords: \(self.endCoords)\n
            timeUntilDeparture: \(self.timeUntilDeparture)\n
        """
        
        return mainDescription
        
    }
    
    func numberOfBusRoutes() -> Int {
        
        var numberOfRoutes = 0
        for direction in directions {
            if direction.type == .depart {
                numberOfRoutes += 1
            }
        }
        
        return numberOfRoutes
        
    }
    
}
