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
    
    // to be removed
    var travelDistance = 0.0

    required init(json: JSON) throws {
        super.init()
        
        print(json["data"])
        
        let jsonData = json["data"]
        
        departureTime = Date(timeIntervalSince1970: jsonData["departureTime"].doubleValue)
        arrivalTime = Date(timeIntervalSince1970: jsonData["arrivalTime"].doubleValue)
        startCoords = CLLocationCoordinate2D(latitude: jsonData["startCoords"]["latitude"].doubleValue,
                               longitude: jsonData["startCoords"]["longitude"].doubleValue)
        endCoords = CLLocationCoordinate2D(latitude: jsonData["endCoords"]["latitude"].doubleValue,
                                           longitude: jsonData["endCoords"]["longitude"].doubleValue)
        
        directions = jsonData["directions"].arrayValue.flatMap { (directionJSON) -> Direction in
            return Direction(from: directionJSON)
        }
        
        var index = 0
        var kmlData = jsonData["kmls"].arrayObject as! [String]
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
    
    private func getRouteSummary(fromJson json: [JSON]) -> [RouteSummaryObject] {
        var routeSummary = [RouteSummaryObject]()
        for routeSummaryJson in json {
            let routeSummaryObject = try! RouteSummaryObject(json: routeSummaryJson)
            routeSummary.append(routeSummaryObject)
        }
        
        return routeSummary
    }

    /// Modify the last routeSummaryObject to include name of the destination place result
    func updatePlaceDestination(_ placeDestination: PlaceResult){
        routeSummary[routeSummary.count - 1].name = placeDestination.name
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

