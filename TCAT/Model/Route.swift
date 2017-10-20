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
    
    required init(json: JSON) throws {
        
        super.init()
        
        print("Route json:", json)
        
        let baseTime = json["baseTime"].doubleValue
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
        
        // Create directions
        for (index, path) in json["path"].arrayValue.enumerated() {
            
            let direction = Direction(from: path, baseTime: baseTime)
            directions.append(direction)
            
            // Create pair ArriveDirection after DepartDirection
            if direction.type == .depart {
                let arriveDirection = direction
                arriveDirection.type = .arrive
                arriveDirection.startTime = arriveDirection.endTime
                arriveDirection.startLocation = arriveDirection.endLocation
                arriveDirection.busStops = []
                arriveDirection.locationName = path["end"]["name"].stringValue
                directions.append(arriveDirection)
            }
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
    
    static func getRoutesArray(fromJson json: JSON) -> [Route] {
        
        if !json["success"].boolValue {
            return []
        }

        let jsonData = json["data"]
        var routes: [Route] = []

        for resultsJSON in jsonData["results"].arrayValue {
            var routeJSON = resultsJSON
            routeJSON["baseTime"] = jsonData["baseTime"]
            let route = try! Route(json: routeJSON)
            routes.append(route)
        }

        return routes
        
    }
    
    private func getRouteSummary(from json: [JSON]) -> [RouteSummaryObject] {
        var routeSummary = [RouteSummaryObject]()
        
        for routeSummaryJson in json {
            let routeSummaryObject = try! RouteSummaryObject(json: routeSummaryJson)
            routeSummary.append(routeSummaryObject)
        }
        
        if let lastRouteSummaryJson = json.last {
            let endingDestination = RouteSummaryObject(name: lastRouteSummaryJson["end"]["name"].stringValue, type: .stop)
            
            routeSummary.append(endingDestination)
        }

        return routeSummary
    }


    // MARK: Process raw routes

    /**
     * Modify the first routeSummaryObject if the name is "Start"
     *  If the starting place is a place result or current location
     *      AND the route summary array count is more than 2 (has a route that is more than simply walking)
     *      remove the first routeSummaryObject
     *  Else (the first routeSummaryObject is a bus stop), so simply update the name to the name the user searched for
     */
    func updateStartingDestination(_ place: Place) {
        if let firstRouteSummaryObject = routeSummary.first {
            if firstRouteSummaryObject.name == "Start" {
                if (place is PlaceResult || (place is BusStop && place.name == "Current Location")) && routeSummary.count > 2 {
                    routeSummary.remove(at: 0)
                } else {
                    routeSummary.first?.updateName(from: place)
                }
            }
        }
    }

    /** Update pin type of the last routeSummaryObject if routeSummaryObject has the same name as the user searched for
     *   OR if the routeSummaryObject's name is "End"
     */
    func updateEndingDestination(_ place: Place) {
        if let lastRouteSummaryObject = routeSummary.last {
            if(lastRouteSummaryObject.name == place.name || lastRouteSummaryObject.name == "End") {
                let type = place is BusStop ? PinType.stop : PinType.place
                lastRouteSummaryObject.type = type
            }
        }
    }

    /// Add walking directions
    func addWalkingDirections(){
        for index in 0..<directions.count {
            let direction = directions[index]
            if direction.type == .walk {
                calculateWalkingDirections(direction) { (path) in
                    direction.path = path
                }
            }
        }
    }

    private func calculateWalkingDirections(_ direction: Direction, _ completion: @escaping ([CLLocationCoordinate2D]) -> Void) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: direction.startLocation.coordinate, addressDictionary: [:]))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: direction.endLocation.coordinate, addressDictionary: [:]))
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            completion(response?.routes.first?.polyline.coordinates ?? [])
        }
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
