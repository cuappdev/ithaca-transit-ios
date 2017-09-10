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
        let now = Date() //curent date
        return Time.dateComponents(from: now, to: departureTime)
    }
    
    var directions: [Direction] = [Direction]()
    var mainStops: [String] = [String]()
    var allStops : [String] = [String]()
    var mainStopNums: [Int] = [Int]() // n > 0 for bus number, -1 for walking, -2 for destinations that are bus stops, -3 for destinations that are places
    var path: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var travelDistance: Double = 0.0 // of first stop
    var lastStopTime: Date = Date() // the critical last time a bus route runs
    
    required init(json: JSON) throws {
        super.init()
        print(json["data"])
        let jsonData = json["data"]
        departureTime = Date(timeIntervalSince1970: jsonData["departureTime"].doubleValue)
        arrivalTime = Date(timeIntervalSince1970: jsonData["arrivalTime"].doubleValue)
        // directions = directionJSON(json:json["directions"].arrayValue)
        mainStops = jsonData["mainStops"].arrayObject as! [String]
        mainStopNums = jsonData["mainStopNums"].arrayObject as! [Int]
        path = CLLocationCoordinate2D.strToCoords(jsonData["kmls"].stringValue)
        
        travelDistance = directions.first != nil ? directions.first!.travelDistance : 0.0
        
        lastStopTime = Date()
    }
    
    init(departureTime: Date,
         arrivalTime: Date,
         directions: [Direction],
         mainStops: [String],
         mainStopsNums: [Int],
         path: [CLLocationCoordinate2D],
         travelDistance: Double,
         lastStopTime: Date = Date()) {
        
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.directions = directions
        self.mainStops = mainStops
        self.mainStopNums = mainStopsNums
        self.path = path
        self.travelDistance = travelDistance
        self.lastStopTime = lastStopTime
        
    }

    /// Modify mainStops and mainStopsNums to include the destination place result
    func addPlaceDestination(_ placeDestination: PlaceResult){
        mainStopNums[mainStops.count - 1] = -2 //to add walk line from last bus stop to place result destination
        mainStops.append(placeDestination.name)
        mainStopNums.append(-3) //place result destination dot
    }
    
    //For debugging purposes
    func printRoute(){
        var mainStopsStr = "("
        for mainStop in mainStops{
            mainStopsStr += "\(mainStop), "
        }
        mainStopsStr += ")"
        var mainStopsNumsStr = "("
        for mainStopNum in mainStopNums{
            mainStopsNumsStr += "\(mainStopNum), "
        }
        mainStopsNumsStr += ")"
        print("departureTime: \(departureTime), arrivalTime: \(arrivalTime)")
        print("mainStops: \(mainStopsStr), mainStopsNums:  \(mainStopsNumsStr)")
    }
}

