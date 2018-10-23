//
//  Network+Models.swift
//  TCAT
//
//  Created by Austin Astorga on 4/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON
import TRON
import CoreLocation
import Alamofire

struct Error: JSONDecodable, Codable {
    init(json: JSON) {}
    
    var error: String!
}
struct AlertRequest: Codable {
    var success: Bool!
    var data: [Alert]!
}

struct Alert: Codable {
    var id: Int!
    var message: String!
    var fromDate: String!
    var toDate: String!
    var fromTime: String!
    var toTime: String!
    var priority: Int!
    var daysOfWeek: String!
    var routes: [Int]!
    var sigs: [Int]!
    var channelMessages: [ChannelMessage]!
}

struct ChannelMessage: Codable {
    var ChannelId: Int!
    var message: String!
}

class AllBusStops: JSONDecodable {
    var allStops : [BusStop] = [BusStop]()
    
    required init(json: JSON) throws {
        if json["success"].boolValue {
            let data = json["data"].arrayValue
            allStops = parseAllStops(json: data)
        }
    }
    
    func parseAllStops(json: [JSON]) -> [BusStop] {
        var allStopsArray = [BusStop]()
        for stop in json {
            let busStop = BusStop(
                name: stop["name"].stringValue,
                lat: stop["lat"].doubleValue,
                long: stop["long"].doubleValue
            )
            allStopsArray.append(busStop)
        }
        
        /* These next few lines take duplicate stops and find the middle coordinate between
         * them and will use that as the condensed bus stop if they are less than 0.1 miles apart
         * else just use both stops because they are far apart
         */
        let crossReference = allStopsArray.reduce(into: [String: [BusStop]]()) {
            $0[$1.name, default: []].append($1)
        }
        
        var nonDuplicateStops = crossReference.filter {$1.count == 1}.map { (key, value) -> BusStop in
            return value.first!
        }
        
        let duplicates = crossReference.filter { $1.count > 1 }
        
        var middleGroundBusStops: [BusStop] = []
        for key in duplicates.keys {
            if let currentBusStops = duplicates[key], let first = currentBusStops.first, let second = currentBusStops.last {
                let firstStopLocation = CLLocation(latitude: first.lat, longitude: first.long)
                let secondStopLocation = CLLocation(latitude: second.lat, longitude: second.long)
                
                let distanceBetween = firstStopLocation.distance(from: secondStopLocation)
                let middleCoordinate = firstStopLocation.coordinate.middleLocationWith(location: secondStopLocation.coordinate)
                if distanceBetween < Constants.Values.maxDistanceBetweenStops {
                    let middleBusStop = BusStop(name: first.name, lat: middleCoordinate.latitude, long: middleCoordinate.longitude)
                    middleGroundBusStops.append(middleBusStop)
                } else {
                    nonDuplicateStops.append(contentsOf: [first, second])
                }
            }
        }
        nonDuplicateStops.append(contentsOf: middleGroundBusStops)
        
        let sortedStops = nonDuplicateStops.sorted(by: {$0.name.uppercased() < $1.name.uppercased()})
        return sortedStops
    }
}

class BusLocationResult: JSONDecodable {
    
    var busLocations: [BusLocation] = []
    
    required init(json: JSON) throws {
        if json["success"].boolValue {
            self.busLocations = json["data"].arrayValue.map {
                parseBusLocation(json: $0)
            }
        } else {
            print("BusLocation Init Failure")
        }
    }
    
    func parseBusLocation(json: JSON) -> BusLocation {
        
        let dataType: BusDataType = {
            switch json["case"].stringValue {
            case "noData" : return .noData
            case "validData" : return .validData
            default : return .invalidData
            }
        }()
        
        let busLocation = BusLocation(
            dataType: dataType,
            destination: json["destination"].stringValue,
            deviation: json["deviation"].intValue,
            delay: json["delay"].intValue,
            direction: json["direction"].stringValue,
            displayStatus: json["displayStatus"].stringValue,
            gpsStatus: json["gpsStatus"].intValue,
            heading: json["heading"].intValue,
            lastStop: json["lastStop"].stringValue,
            lastUpdated: Date(timeIntervalSince1970: json["lastUpdated"].doubleValue),
            latitude: json["latitude"].doubleValue,
            longitude: json["longitude"].doubleValue,
            name: json["name"].intValue,
            opStatus: json["opStatus"].stringValue,
            routeID: json["routeID"].stringValue,
            runID: json["runID"].intValue,
            speed: json["speed"].intValue,
            tripID: json["tripID"].stringValue,
            vehicleID: json["vehicleID"].intValue
        )
        
        return busLocation
        
    }
    
}
