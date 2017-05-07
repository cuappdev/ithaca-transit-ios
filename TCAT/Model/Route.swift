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
//
//          Example: (One Route Stop Details screen)
//Route:
//    departureTime = 7:21 PM
//    arrivalTime = 7:39 PM
//    timeUntilDeparture = 5 min
//    directions = [WalkDirection1, BoardDirection, WalkDirection2]
//    mainStops = ["BakerFlagpole", "Angry Mom Records"]
//
//WalkDirection1:
//    departureTime = 7:21 PM
//    departurePlace = "Statler Hall"
//    departureDescription = "Walk to Statler Hall"
//    travelDistance = 0.2
//
//BoardDirection:
//    routeNumber = 32
//    bound = inbound
//    stops = ["Bus Stop Name", "Bus Stop Name", "Bus Stop Name"]
//    departureTime = 7:24 PM
//    departurePlace = "Statler Hall"
//    arrivalTime = 7:36 PM
//    arrivalPlace = "Ithaca Commons"
//    arrivalDescription = "Debark at Ithaca Commons"
//    travelTime = 12 min
//
//WalkDirection2:
//    departureTime = 7:39 PM
//    departurePlace = "Angry Mom Records"
//    departureDescription = "Walk to Angry Mom Records"
//    travelDistance = 0.2
//
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
    
    //NSELF: REMOVE FROM EXAMPLE
    /*To extract timeUntilDeparture's times in day, hour, and minute units:
     * let days: Int = timeUntilDeparture.day
     * let hours: Int = timeUntilDeparture.hour
     * let minutes: Int = timeUntilDeparture.minute
     */
    var timeUntilDeparture: DateComponents {
        let now = Date() //curent date
        return Time.dateComponents(from: now, to: departureTime)
    }
    
    var directions: [Direction] = [Direction]()
    var mainStops: [String] = [String]()
    //N2SELF: ADD TO EXAMPLE
    var allStops : [String] = [String]()
    var mainStopsNums: [Int] = [Int]()//-1 for pins
    var travelDistance: Double = 0.0 //of first stop
    var lastStopTime: Date = Date()// the critical last time a bus route runs
    
    required init(json: JSON) throws {
        super.init()
        print(json)
        departureTime = Time.date(from: json["departureTime"].stringValue)
        arrivalTime = Time.date(from: json["arrivalTime"].stringValue)
        directions = directionJSON(json:json["directions"].array!)
        //We need all stopNames for matt but not monica
        mainStops = json["mainStopNames"].arrayObject as! [String]
        allStops = json["allStopNames"].arrayObject as! [String]
        mainStopsNums = json["stopNumbers"].arrayObject as! [Int]
        travelDistance = directions[0] is WalkDirection ? (directions[0] as! WalkDirection).travelDistance : 0.0
        lastStopTime = Date()
    }
    
    init(departureTime: Date, arrivalTime: Date, directions: [Direction], mainStops: [String], mainStopsNums: [Int], travelDistance: Double, lastStopTime: Date = Date()) {
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.directions = directions
        self.mainStops = mainStops
        self.mainStopsNums = mainStopsNums
        self.travelDistance = travelDistance
        self.lastStopTime = lastStopTime
    }
    
    
    func directionJSON(json: [JSON]) -> [Direction] {
        var directionArray = [Direction]()
        for direction in json {
            let directionType = direction["directionType"].stringValue
            if directionType == "walk" {
                directionArray.append(walkDirection(json: direction))
            } else if directionType == "depart" {
                directionArray.append(departDirection(json: direction))
            } else if directionType == "arrive"{
                directionArray.append(arriveDirection(json: direction))
            } else {
                //Direction isn't valid.
            }
        }
        return directionArray
    }
    
    
    func walkDirection(json: JSON) -> WalkDirection {
        let time = Time.date(from: json["time"].stringValue)
        let place = json["place"].stringValue
        let location = CLLocation(latitude: json["location"][0].doubleValue, longitude: json["location"][1].doubleValue)
        let travelDistance = json["travelDistance"].doubleValue
        let destinationLocation = CLLocation(latitude: json["destinationLocation"][0].doubleValue,
                                             longitude: json["destinationLocation"][1].doubleValue)
        return WalkDirection(time: time, place: place, location: location, travelDistance: travelDistance,
                             destination: destinationLocation)
    }
    
    
    func departDirection(json: JSON) -> DepartDirection {
        let time = Time.date(from: json["time"].stringValue)
        let place = json["place"].stringValue
        let location = CLLocation(latitude: json["location"][0].doubleValue, longitude: json["location"][1].doubleValue)
        let routeNumber = json["routeNumber"].intValue
        let bound = Bound(rawValue: json["bound"].stringValue)
        let stops = json["stops"].arrayObject as! [String]
        let arrivalTime = Time.date(from: json["arrivalTime"].stringValue)
        let kmlString = json["kml"].stringValue
        let path = CLLocationCoordinate2D.strToCoords(kmlString)
        return DepartDirection(time: time, place: place, location: location, path: path,
                               routeNumber: routeNumber, bound: bound!, stops: stops, arrivalTime: arrivalTime)
    }
    
    
    func arriveDirection(json: JSON) -> ArriveDirection {
        let time = Time.date(from: json["time"].stringValue)
        let place = json["place"].stringValue
        let location = CLLocation(latitude: json["location"][0].doubleValue, longitude: json["location"][1].doubleValue)
        return ArriveDirection(time: time, place: place, location: location)   
    }
    
    //For debugging purposes
    func printRoute(){
        var mainStopsStr = "("
        for mainStop in mainStops{
            mainStopsStr += "\(mainStop), "
        }
        mainStopsStr += ")"
        var mainStopsNumsStr = "("
        for mainStopNum in mainStopsNums{
            mainStopsNumsStr += "\(mainStopNum), "
        }
        mainStopsNumsStr += ")"
        print("departureTime: \(departureTime), arrivalTime: \(arrivalTime)")
        print("mainStops: \(mainStopsStr), mainStopsNums:  \(mainStopsNumsStr)")
    }
}

