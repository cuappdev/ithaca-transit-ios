//
//  Route.swift
//  TCAT
//
//  Description:
//      Data model to represent both route options screen (Monica) and route detail screen (Matt)
//
//  Note:
//      - mainStops is for route options screen (Monica) and directions is for route detail screen (Matt)
//      - departureTime and arrivalTime are for the entire route, while each direction has their own departure (and possibly arrival time)
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
import UIKit
import TRON
import SwiftyJSON
import CoreLocation
import MapKit

class Route: NSObject, JSONDecodable {
    
    var baseTime: Double!
    var departureTime: Date = Date()
    var arrivalTime: Date = Date()
    
    var timeUntilDeparture: DateComponents {
        let now = Date()
        return Time.dateComponents(from: now, to: departureTime)
    }
    
    var startCoords: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var endCoords: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var directions: [Direction] = [Direction]()
    var routeSummary: [RouteSummaryObject] = [RouteSummaryObject]()
    
    var travelDistance: Double?
    weak var travelDistanceDelegate: TravelDistanceDelegate?
    
    required init(json: JSON) throws {
        
        super.init()
        
        baseTime = json["baseTime"].doubleValue
        let data = json["path"]
        
        let pathStart = 0
        let pathEnd = data.arrayValue.count - 1
        
        // Peek at first direction to get start time
        // MARK: Can this be provided at top level of each route?
        departureTime = Date(timeIntervalSince1970: baseTime + data[pathStart]["startTime"].doubleValue)
        arrivalTime = Date(timeIntervalSince1970: baseTime + json["arrivalTime"].doubleValue)
        
        startCoords = CLLocationCoordinate2D(latitude: data[pathStart]["start"]["location"]["latitude"].doubleValue,
                                             longitude: data[pathStart]["start"]["location"]["longitude"].doubleValue)
        endCoords = CLLocationCoordinate2D(latitude: data[pathEnd]["end"]["location"]["latitude"].doubleValue,
                                           longitude: data[pathEnd]["end"]["location"]["longitude"].doubleValue)
        
        var busInvolved = false
        
        let lastIsBusStop = getAllBusStops().first(where: { (stop) -> Bool in
            let stopCoordinates = CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.long)
            return stopCoordinates == endCoords
        }) != nil
        
        // Create directions
        for (index, path) in json["path"].arrayValue.enumerated() {
            
            // print("\(index), path:", path)
            
            let direction = Direction(from: path, baseTime: baseTime)
            if index == json["path"].arrayValue.count - 1 {
                direction.locationName = json["endName"].string ?? "Null"
            }
            directions.append(direction)
            
            // Create pair ArriveDirection after DepartDirection
            if direction.type == .depart {
                busInvolved = true
                let arriveDirection = direction.copy() as! Direction
                arriveDirection.type = .arrive
                arriveDirection.startTime = arriveDirection.endTime
                arriveDirection.startLocation = arriveDirection.endLocation
                arriveDirection.busStops = []
                
                arriveDirection.locationName = index == json["path"].arrayValue.count - 1 && lastIsBusStop ?
                    json["endName"].stringValue :
                    path["end"]["name"].stringValue
                
                directions.append(arriveDirection)
            }
            
        }
        
        // Create final direction to walk (if destination not a bus stop) from last bus option to final destination
        
        if busInvolved && !lastIsBusStop {
            
            print("FINAL DIRECTION")
            let finalDirection = Direction(locationName: json["endName"].string ?? "Null")
            finalDirection.type = .walk
            finalDirection.startLocation = directions.last!.endLocation
            finalDirection.endLocation = CLLocation(latitude: endCoords.latitude, longitude: endCoords.longitude)
            finalDirection.startTime = directions.last!.endTime
            finalDirection.endTime = arrivalTime
            
            // path should be set in bulk walk calculations
            directions.append(finalDirection)
            
        }
        
        routeSummary = getRouteSummary(from: json["path"].arrayValue)
        
    }
    
    init(departureTime: Date,
         arrivalTime: Date,
         startCoords: CLLocationCoordinate2D,
         endCoords: CLLocationCoordinate2D,
         directions: [Direction],
         routeSummary: [RouteSummaryObject]) {
        
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.startCoords = startCoords
        self.endCoords = endCoords
        self.directions = directions
        self.routeSummary = routeSummary
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
            routeSummaryObject.time = Date(timeIntervalSince1970: baseTime + routeSummaryJson["startTime"].doubleValue) // fix time to include base time
            routeSummary.append(routeSummaryObject)
        }
        
        if let lastRouteSummaryJson = json.last {
            let long = lastRouteSummaryJson["end"]["location"]["longitude"].doubleValue
            let lat = lastRouteSummaryJson["end"]["location"]["latitude"].doubleValue
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let time = Date(timeIntervalSince1970: baseTime + lastRouteSummaryJson["endTime"].doubleValue)
            
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
    
    /** Calculate travel distance from location passed in to first route summary object and updates travel distance of route
     */
    func calculateTravelDistance(fromLocation location: CLLocationCoordinate2D) {
        guard let firstRouteSummary = routeSummary.first else {
            return
        }
        
        let fromLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let endLocation = CLLocation(latitude: firstRouteSummary.location.latitude, longitude: firstRouteSummary.location.longitude)
        
        let distance = fromLocation.distance(from: endLocation)
        self.travelDistance = distance * 0.000621371192 // convert meters to miles
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
                
                if lastRouteSummaryObject.name == "End" {
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
        
        //        mainDescription += "routeSummary:\n"
        //        for (index, object) in self.routeSummary.enumerated() {
        //            mainDescription += """
        //                --- RouteSummary[\(index)] ---\n
        //                name: \(object.name)\n
        //                type: \(object.type)\n
        //                number: \(object.busNumber ?? -1)\n
        //                nextDirection: \(object.nextDirection as Any)
        //            """
        //        }
        
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
