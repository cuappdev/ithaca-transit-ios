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
    var mainStopsNums: [Int] = [Int]()//-1 for pins
    var travelDistance: Double = 0.0 //of first stop
    var lastStopTime: Date = Date()// the critical last time a bus route runs
    
   
    
    required init(json: JSON) throws {
        super.init()
        print(json)
        departureTime = timeToDate(time: json["departureTime"].stringValue)
        arrivalTime = timeToDate(time: json["arrivalTime"].stringValue)
        directions = directionJSON(json:json["directions"].array!)
        mainStops = json["stopNames"].arrayObject as! [String]
        mainStopsNums = json["stopNumbers"].arrayObject as! [Int]
        travelDistance = (directions[0] as! WalkDirection).travelDistance
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
            } else {
                directionArray.append(arriveDirection(json: direction))
            }
        }
        return directionArray
    }
    
    func walkDirection(json: JSON) -> WalkDirection {
        let time = timeToDate(time: json["time"].stringValue)
        let place = json["place"].stringValue
        let location = CLLocation(latitude: json["location"][0].doubleValue, longitude: json["location"][1].doubleValue)
        let travelDistance = json["travelDistance"].doubleValue
        return WalkDirection(time: time, place: place, location: location, travelDistance: travelDistance)
    }
    func departDirection(json: JSON) -> DepartDirection {
        let time = timeToDate(time: json["time"].stringValue)
        let place = json["place"].stringValue
        let location = CLLocation(latitude: json["location"][0].doubleValue, longitude: json["location"][1].doubleValue)
        let routeNumber = json["routeNumber"].intValue
        
        let bound = Bound(rawValue: json["bound"].stringValue)
        let stops = json["stops"].arrayObject as! [String]
        let arrivalTime = timeToDate(time: json["arrivalTime"].stringValue)
        return DepartDirection(time: time, place: place, location: location, routeNumber: routeNumber, bound: bound!, stops: stops, arrivalTime: arrivalTime)
        
    }
    func arriveDirection(json: JSON) -> ArriveDirection {
        let time = timeToDate(time: json["time"].stringValue)
        let place = json["place"].stringValue
        let location = CLLocation(latitude: json["location"][0].doubleValue, longitude: json["location"][1].doubleValue)
        return ArriveDirection(time: time, place: place, location: location)
        
    }
    
    func timeToDate(time: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.date(from: time)!
    }
}
