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
        departureTime = Date(timeIntervalSince1970: json["departureTime"].doubleValue)
        arrivalTime = Date(timeIntervalSince1970: json["arrivalTime"].doubleValue)

        startCoords = CLLocationCoordinate2D(latitude: json["startCoords"]["latitude"].doubleValue,
                               longitude: json["startCoords"]["longitude"].doubleValue)
        endCoords = CLLocationCoordinate2D(latitude: json["endCoords"]["latitude"].doubleValue,
                                           longitude: json["endCoords"]["longitude"].doubleValue)
        
        routeSummary = getRouteSummary(fromJson: json["routeSummary"].arrayValue)
        
        directions = json["directions"].arrayValue.flatMap { (directionJSON) -> Direction in
            return Direction(from: directionJSON)
        }

        var index = 0
        var kmlData = json["kmls"].arrayObject as! [String]
        for direction in directions {
            if direction.type == .depart {
                direction.path = CLLocationCoordinate2D.strToCoords(kmlData[index])
                index += 1
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
        if (!json["success"].boolValue) {
            return []
        }

        let routeJsonArray = json["data"].arrayValue
        var routes: [Route] = []

        for routeJson in routeJsonArray {
            let route = try! Route(json: routeJson)
            routes.append(route)
        }

        return routes
    }

    private func getRouteSummary(fromJson json: [JSON]) -> [RouteSummaryObject] {
        var routeSummary = [RouteSummaryObject]()
        for routeSummaryJson in json {
            let routeSummaryObject = try! RouteSummaryObject(json: routeSummaryJson)
            routeSummary.append(routeSummaryObject)
        }

        return routeSummary
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
