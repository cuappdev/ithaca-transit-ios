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
        
        let baseTime = json["baseTime"].doubleValue
        
        departureTime = Date(timeIntervalSince1970: baseTime)
        arrivalTime = Date(timeIntervalSince1970: baseTime + json["arrivalTime"].doubleValue)

        startCoords = CLLocationCoordinate2D(latitude: json["start"]["location"]["latitude"].doubleValue,
                               longitude: json["start"]["location"]["longitude"].doubleValue)
        endCoords = CLLocationCoordinate2D(latitude: json["end"]["location"]["latitude"].doubleValue,
                                           longitude: json["end"]["location"]["longitude"].doubleValue)
        
        
        /// Append RouteSummaryObject based on path entry and resulting direction
        func createRouteSummaryObject(at pathIndex: Int, direction: Direction) {
            
            // PinType: stop, place, currentLocation
            // NextDirection: bus, walk
            
            var routeSummaryObject: RouteSummaryObject? = nil
            let name: String = direction.locationName
            // MARK: DO NOT HAVE THIS INFORMATION
            let type: PinType = .stop
            
            // Assumption: walk follows arrival, a bus direction follows walk, depart. Last direction accounted for.
            let nextDirection: NextDirection? = { () -> NextDirection? in
                if pathIndex != json["path"].arrayValue.count - 1 {
                    switch direction.type {
                    case .walk, .depart: return .bus
                    case .arrive: return .walk
                    default: return nil
                    }
                } else {
                    return nil
                }
            }()
            
            // Determine correct initalizer based on data
            if let next = nextDirection {
                if json["busPath"] != JSON.null {
                    let busNumber = json["busPath"]["lineNumber"].intValue
                    routeSummaryObject = RouteSummaryObject(name: name, type: type, nextDirection: next, busNumber: busNumber)
                } else {
                    routeSummaryObject = RouteSummaryObject(name: name, type: type, nextDirection: next)
                }
            } else {
                routeSummaryObject = RouteSummaryObject(name: name, type: type)
            }
            
            if let object = routeSummaryObject {
                routeSummary.append(object)
            }
        
        }
        
        // Create directions
        for (index, path) in json["path"].arrayValue.enumerated() {
            
            let direction = Direction(from: path, baseTime: baseTime)
            directions.append(direction)
            createRouteSummaryObject(at: index, direction: direction)
            
            // Create pair ArriveDirection after DepartDirection
            if direction.type == .depart {
                let arriveDirection = direction
                arriveDirection.type = .arrive
                arriveDirection.startTime = arriveDirection.endTime
                arriveDirection.startLocation = arriveDirection.endLocation
                arriveDirection.busStops = []
                arriveDirection.locationName = path["end"]["name"].stringValue
                directions.append(arriveDirection)
                createRouteSummaryObject(at: index, direction: arriveDirection)
            }
            
        }
        
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


    // MARK: Process raw routes

    /// Modify the first routeSummaryObject to include name of the starting place
    func updateStartingDestination(_ place: Place) {
        routeSummary.first?.updateNameAndPin(fromPlace: place)
    }

    /// Modify the last routeSummaryObject to include name of the ending place
    func updateEndingDestination(_ place: Place) {
        routeSummary.last?.updateNameAndPin(fromPlace: place)
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
