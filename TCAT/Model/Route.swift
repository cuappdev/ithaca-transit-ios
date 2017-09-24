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
        let now = Date() //curent date
        return Time.dateComponents(from: now, to: departureTime)
    }
    
    var routeSummary: [RouteSummaryObject] = [RouteSummaryObject]()
    var directions: [Direction] = [Direction]()
    var allStops : [String] = [String]()
    var paths: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var travelDistance: Double = 0.0 // of first stop
    var lastStopTime: Date = Date() // the critical last time a bus route runs
    
    required init(json: JSON) throws {
        super.init()
        departureTime = Date(timeIntervalSince1970: json["departureTime"].doubleValue)
        arrivalTime = Date(timeIntervalSince1970: json["arrivalTime"].doubleValue)
        routeSummary = getRouteSummary(fromJson: json["routeSummary"].arrayValue)
        // directions = directionJSON(json:json["directions"].arrayValue)
        paths = CLLocationCoordinate2D.strToCoords(json["kmls"].stringValue)
        
        travelDistance = directions.first != nil ? directions.first!.travelDistance : 0.0
        
        lastStopTime = Date()
    }
    
    init(departureTime: Date,
         arrivalTime: Date,
         routeSummary: [RouteSummaryObject],
         directions: [Direction],
         path: [CLLocationCoordinate2D],
         travelDistance: Double,
         lastStopTime: Date = Date()) {
        
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.routeSummary = routeSummary
        self.directions = directions
        self.paths = path
        self.travelDistance = travelDistance
        self.lastStopTime = lastStopTime
    }
    
    static func getRoutesArray(fromJson json: JSON) -> [Route] {
        if (json["success"]=="false") {
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
    
    /// Modify the first routeSummaryObject to include name of the starting destination place result
    func updateStartingDestination(_ placeResult: PlaceResult) {
        routeSummary.first?.name = placeResult.name
    }
    
    /// Modify the last routeSummaryObject to include name of the ending place result
    func updateEndingDestinationName(_ placeResult: PlaceResult) {
        routeSummary.last?.name = placeResult.name
    }
    
    /// Add walking directions
    func addWalkingDirections(){
        for index in 0..<directions.count {
            let direction = directions[index]
            if direction.type == .walk {
                calculateWalkingDirections(direction) { (path) in
//                   paths.insert(path, at: index)
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
    
}

