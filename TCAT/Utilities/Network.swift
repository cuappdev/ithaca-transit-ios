//
//  Network.swift
//  TCAT
//
//  Created by Austin Astorga on 4/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
import Foundation
import SwiftyJSON
import TRON
import CoreLocation
import GooglePlaces

class Network {
    
    // Use your own IP Address (changes!)
    static let ipAddress = "192.168.1.8"
    
    static let source = "\(ipAddress):3000" // Old Backend Endpoint: "34.235.128.17"
    static let tron = TRON(baseURL: "http://\(source)/")
    static let googleTron = TRON(baseURL: "https://maps.googleapis.com/maps/api/place/autocomplete/")
    static let placesClient = GMSPlacesClient.shared()
    
    class func getAllStops() -> APIRequest<AllBusStops, Error> {
        let request: APIRequest<AllBusStops, Error> = tron.swiftyJSON.request("stops")
        request.method = .get
        return request
    }
    
    class func getStartEndCoords(start: CoordinateAcceptor, end: CoordinateAcceptor, callback:@escaping ((CLLocationCoordinate2D?, CLLocationCoordinate2D?) -> Void)) {
        let visitor = CoordinateVisitor()
        start.accept(visitor: visitor) { startCoord in
            end.accept(visitor: visitor) { endCoord in
                
                callback(startCoord, endCoord)
            }
        }
    }
    
    class func getRoutes(start: CoordinateAcceptor, end: CoordinateAcceptor, time: Date, type: SearchType, callback:@escaping ((APIRequest<JSON, Error>) -> Void)) {
        getStartEndCoords(start: start, end: end) { startCoords, endCoords in
            
            let request: APIRequest<JSON, Error> = tron.swiftyJSON.request("route")
            
            request.parameters = [
                "start"  :   "\(startCoords?.latitude ??? ""),\(startCoords?.longitude ??? "")",
                "end"    :   "\(endCoords?.latitude ??? ""),\(endCoords?.longitude ??? "")",
            ]
            
            if type == .arriveBy {
                request.parameters["depart_time"] = time.timeIntervalSince1970
            } else {
                request.parameters["time"] = time.timeIntervalSince1970
            }
            
            request.method = .get
            
            // for debugging
            //            print("Request URL: http://\(source)/\(request.path)?end=\(request.parameters["end"]!)&start=\(request.parameters["start"]!)&time=\(request.parameters["time"]!)")
            
            callback(request)
        }
    }
    
    
    class func getGooglePlaces(searchText: String) -> APIRequest<JSON, Error> {
        let googleJson = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "config", withExtension: "json")!))
        let request: APIRequest<JSON, Error> = googleTron.swiftyJSON.request("json")
        request.parameters = [
            "strictbounds" : "",
            "location" : "42.4440,-76.5019",
            "radius" : 24140,
            "input" : searchText,
            "key" : googleJson["google-places"].stringValue
        ]
        request.method = .get
        return request
    }
    
    class func getBusLocations(routeID: String) -> APIRequest<AllBusLocations, Error> {
        let request: APIRequest<AllBusLocations, Error> = tron.swiftyJSON.request("tracking")
        request.parameters = ["routeID" : routeID]
        request.method = .get
        return request
    }
    
}

class Error: JSONDecodable {
    required init(json: JSON) {
        // need to talk to shiv about what errors could be possibily returned
    }
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
            let name = stop["name"].stringValue
            let location = stop["location"]
            let lat = location["latitude"].doubleValue
            let long = location["longitude"].doubleValue
            let busStop = BusStop(name: name, lat: lat, long: long)
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
        let duplicates = crossReference
            .filter { $1.count > 1 }

        // 160 meters = 0.1 miles
        var middleGroundBusStops: [BusStop] = []
        for key in duplicates.keys {
            if let currentBusStops = duplicates[key], let first = currentBusStops.first, let second = currentBusStops.last {
                let firstStopLocation = CLLocation(latitude: first.lat, longitude: first.long)
                let secondStopLocation = CLLocation(latitude: second.lat, longitude: second.long)

                let distanceBetween = firstStopLocation.distance(from: secondStopLocation)
                let middleCoordinate = firstStopLocation.coordinate.middleLocationWith(location: secondStopLocation.coordinate)
                if distanceBetween < Key.Distance.maxBetweenStops {
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

class AllBusLocations: JSONDecodable {

    var allBusLocations : [BusLocation] = [BusLocation]()

    required init(json: JSON) throws {
        
        if json["success"].boolValue {
            let data = json["data"].arrayValue
            allBusLocations = parseAllLocations(json: data)
        }
    }

    func parseAllLocations(json: [JSON]) -> [BusLocation] {

        var allLocationsArray = [BusLocation]()

        for bus in json {

            let routeID = bus["routeID"].stringValue
            let busLocation = BusLocation(routeID: routeID)

            busLocation.destination = bus["destination"].stringValue
            busLocation.deviation = bus["deviation"].intValue
            busLocation.direction = bus["direction"].stringValue
            busLocation.displayStatus = bus["displayStatus"].stringValue
            busLocation.gpsStatus = bus["gpsStatus"].intValue
            busLocation.heading = bus["heading"].intValue
            busLocation.lastStop = bus["lastStop"].stringValue
            busLocation.lastUpdated = Date(timeIntervalSince1970: bus["lastUpdated"].doubleValue)
            busLocation.latitude = bus["latitude"].doubleValue
            busLocation.longitude = bus["longitude"].doubleValue
            busLocation.name = bus["name"].intValue
            busLocation.opStatus = bus["opStatus"].stringValue
            busLocation.runID = bus["runID"].intValue
            busLocation.speed = bus["speed"].intValue
            busLocation.tripID = bus["tripID"].intValue
            busLocation.vehicleID = bus["vehicleID"].intValue

            allLocationsArray.append(busLocation)

        }

        return allLocationsArray

    }

}
