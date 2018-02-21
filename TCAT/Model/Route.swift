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
    
    /// The distance between the start and finish location
    var travelDistance: Double {
        let fromLocation = CLLocation(latitude: startCoords.latitude, longitude: startCoords.longitude)
        let toLocation = CLLocation(latitude: endCoords.latitude, longitude: endCoords.longitude)
        return toLocation.distance(from: fromLocation)
    }
    
    /// The most extreme points of the route
    var boundingBox: Bounds
    
    /// The number of transfers in a route. Defaults to 0
    var numberOfTransfers: Int = 0
    
    /// A list of Direction objects (used for Route Detail)
    var directions: [Direction] = [Direction]()

    var routeSummary: [RouteSummaryObject] = [RouteSummaryObject]()
    
    /// The number of minutes the route will take. Returns 0 in case of error.
    var totalDuration: Int {
        return Time.dateComponents(from: departureTime, to: arrivalTime).minute ?? 0
    }
    
    weak var travelDistanceDelegate: TravelDistanceDelegate?
    
    required init(json: JSON) throws {
        
        departureTime = json["departureTime"].parseDate()
        arrivalTime = json["arrivalTime"].parseDate()
        startCoords = json["startCoords"].parseCoordinates()
        endCoords = json["endCoords"].parseCoordinates()
        boundingBox = json["boundingBox"].parseBounds()
        numberOfTransfers = json["numberOfTransfers"].intValue
        directions = json["directions"].arrayValue.map { Direction(from: $0) }
        
        super.init()
        
        // Old Code VVV
        
        // Arrive directions
        // Potential last directions
        
        var busInvolved = false
        
        let lastIsBusStop = SearchTableViewManager.shared.getAllStops().first(where: { (stop) -> Bool in
            let stopCoordinates = CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.long)
            return stopCoordinates == endCoords
        }) != nil
        
        for (index, direction) in directions.enumerated() {
            
            // Create pair ArriveDirection after DepartDirection
            if direction.type == .depart {
                busInvolved = true
                let arriveDirection = direction.copy() as! Direction
                arriveDirection.type = .arrive
                arriveDirection.startTime = arriveDirection.endTime
                arriveDirection.startLocation = arriveDirection.endLocation
                arriveDirection.stops = []
                arriveDirection.name = index == json["path"].arrayValue.count - 1 && lastIsBusStop ?
                    "" : ""
                directions.append(arriveDirection)
            }
            
        }
        
        // Create final direction to walk (if destination not a bus stop) from last bus option to final destination
        
        if busInvolved && !lastIsBusStop {
            
            let finalDirection = Direction(name: json["endName"].string ?? "Null")
            finalDirection.type = .walk
            finalDirection.startLocation = directions.last!.endLocation
            finalDirection.endLocation = endCoords
            finalDirection.startTime = directions.last!.endTime
            finalDirection.endTime = arrivalTime
            
            // path should be set in bulk walk calculations
            directions.append(finalDirection)
            
        }
        
        routeSummary = getRouteSummary(from: json["path"].arrayValue)
        
    }
    
    // MARK: Parse JSON
    
    static func getRoutesArray(fromJson json: JSON, endingAt endName: String) -> [Route] {
        
        if !json["success"].boolValue {
            return []
        }
        
        let jsonData = json["data"]
        var routes: [Route] = []
        
        for resultsJSON in jsonData["results"].arrayValue {
            var routeJSON = resultsJSON
            routeJSON["baseTime"] = jsonData["baseTime"]
            routeJSON["endName"].string = endName
            let route = try! Route(json: routeJSON)
            routes.append(route)
        }
        
        return routes
        
    }
    
    private func getRouteSummary(from json: [JSON]) -> [RouteSummaryObject] {
        
        var routeSummary = [RouteSummaryObject]()
        
        for routeSummaryJson in json {
            let routeSummaryObject = try! RouteSummaryObject(json: routeSummaryJson)
            routeSummaryObject.time = Date(timeIntervalSince1970: routeSummaryJson["startTime"].doubleValue) // fix time to include base time
            routeSummary.append(routeSummaryObject)
        }
        
        if let lastRouteSummaryJson = json.last {
            let long = lastRouteSummaryJson["end"]["location"]["longitude"].doubleValue
            let lat = lastRouteSummaryJson["end"]["location"]["latitude"].doubleValue
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let time = Date(timeIntervalSince1970: lastRouteSummaryJson["endTime"].doubleValue)
            
            let endingDestination = RouteSummaryObject(name: lastRouteSummaryJson["end"]["name"].stringValue, type: .stop, location: location, time: time)
            
            routeSummary.append(endingDestination)
        }
        
        return routeSummary
    }
    
    
    // MARK: Process raw routes
    
    /**
     * Modify the first routeSummaryObject if the name is "Start"
     *  If the starting place is a place result or current location
     *      AND the route summary array count is more than 2 (has a route that is more than simply walking)
     *      remove the first routeSummaryObject and update the time
     *  Else (the first routeSummaryObject is a bus stop), so simply update the name to the name the user searched for
     */
    func updateStartingDestination(_ place: Place) {
        if let firstRouteSummaryObject = routeSummary.first {
            if firstRouteSummaryObject.name == "Start" {
                if (place is PlaceResult || (place is BusStop && place.name == "Current Location")) && routeSummary.count > 2 {
                    routeSummary.remove(at: 0)
                    departureTime = (routeSummary.first?.time)!
                    //                    print("departureTime for \(routeSummary.first?.name) is \(departureTime). The time string is \(Time.timeString(from: departureTime))")
                    //                    print("arrivalTime is \(arrivalTime). The time string is \(Time.timeString(from: arrivalTime))")
                } else {
                    routeSummary.first?.updateName(from: place)
                    
                    if(place is PlaceResult || (place is BusStop && place.name == "Current Location")) {
                        routeSummary.first?.type = .place // current location & place result should have grey dot
                    }
                }
            }
        }
    }
    
    func isWalkingRoute() -> Bool {
        for routeSummaryObj in routeSummary {
            if routeSummaryObj.nextDirection != .walk {
                return false
            }
        }
        
        return true
    }
    
    /** Calculate travel distance from location passed in to first route summary object and updates travel distance of route
     */
    func calculateTravelDistance(fromLocation location: CLLocationCoordinate2D) {
        guard let firstRouteSummary = routeSummary.first else {
            return
        }
        
        let fromLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let endLocation = CLLocation(latitude: firstRouteSummary.location.latitude, longitude: firstRouteSummary.location.longitude)
        
        var distance = fromLocation.distance(from: endLocation)
        distance = distance * 0.000621371192 // convert meters to miles
        self.travelDistanceDelegate?.travelDistanceUpdated(withDistance: distance)
    }
    
    /** Update pin type of the last routeSummaryObject if routeSummaryObject has the same name as the user searched for
     * OR update name and pin type if last routeSummaryObject is "End"
     */
    func updateEndingDestination(_ place: Place) {
        if let lastRouteSummaryObject = routeSummary.last {
            if lastRouteSummaryObject.name == place.name || lastRouteSummaryObject.name == "End" {
                let type = place is BusStop ? PinType.stop : PinType.place
                lastRouteSummaryObject.type = type
                
                // Remove “End” if 2nd-to-last stop has same name as ending destination
                let secondToLastStop = routeSummary.count-2
                if lastRouteSummaryObject.name == "End" && routeSummary.count > 2 && routeSummary[secondToLastStop].name.lowercased() == place.name.lowercased() {
                    routeSummary.removeLast()
                    routeSummary.last?.removeNextDirection() // remove 2nd-to-last stop next direction (so it behaves like ending stop)
                } else if(lastRouteSummaryObject.name == "End") {
                    lastRouteSummaryObject.updateName(from: place)
                }
            }
        }
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
