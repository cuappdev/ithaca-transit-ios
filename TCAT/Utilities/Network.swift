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
import Alamofire

enum NetworkType: String {
    case local, debug, release
}

class Network {
    
    // MARK: Global Network Variables
    
    static let networkType: NetworkType = .release
    static let apiVersion = "v1"
    
    /// Used for local backend testing
    static let localIPAddress = "10.132.6.85"
    static let localSource = "http://\(localIPAddress):3000/api/\(apiVersion)/"
    
    /// Test server used for development
    static let debugIPAddress = "35.174.156.171"
    static let debugSource = "http://\(debugIPAddress)/api/\(apiVersion)/"
    
    /// Deployed server instance used for release
    static let releaseIPAddress = "54.174.47.32"
    static let releaseSource = "http://\(releaseIPAddress)/api/\(apiVersion)/"
    
    /// Network IP address being used for specified networkType
    static var ipAddress: String {
        switch networkType {
        case .local: return localIPAddress
        case .debug: return debugIPAddress
        case .release: return releaseIPAddress
        }
    }
    
    /// Network source currently being used
    static var address: String {
        switch networkType {
        case .local: return localSource
        case .debug: return debugSource
        case .release: return releaseSource
        }
    }
    
    static let mainTron = TRON(baseURL: Network.address)
    static let googleTron = TRON(baseURL: "https://maps.googleapis.com/maps/api/place/autocomplete/")
  
    static let placesClient = GMSPlacesClient.shared()

    class func getAllStops() -> APIRequest<AllBusStops, Error> {
        let request: APIRequest<AllBusStops, Error> = mainTron.swiftyJSON.request("allStops")
        request.method = .get
        return request
    }

    class func getParameterData(start: CoordinateAcceptor, end: CoordinateAcceptor,
                                callback: @escaping (_ start: CLLocationCoordinate2D?, _ end: CLLocationCoordinate2D?) -> Void) {

        let visitor = CoordinateVisitor()
        start.accept(visitor: visitor) { startCoord in
            end.accept(visitor: visitor) { endCoord in
                callback(startCoord, endCoord)
            }
        }
        
    }

    class func getRoutes(start: CoordinateAcceptor, end: CoordinateAcceptor, time: Date, type: SearchType,
                         callback: @escaping ((APIRequest<JSON, Error>?) -> Void)) {

        getParameterData(start: start, end: end) { (startCoords, endCoords) in

            guard let startCoords = startCoords, let endCoords = endCoords else {
                callback(nil)
                return
            }

            let request: APIRequest<JSON, Error> = mainTron.swiftyJSON.request("route")
            request.method = .get
            request.parameters = [
                "arriveBy"          :   type == .arriveBy,
                "end"               :   "\(endCoords.latitude),\(endCoords.longitude)",
                "start"             :   "\(startCoords.latitude),\(startCoords.longitude)",
                "time"              :   time.timeIntervalSince1970
            ]

            // for debugging
            // print("Request URL: \(source)/\(request.path)?end=\(request.parameters["end"]!)&start=\(request.parameters["start"]!)&time=\(request.parameters["time"]!)")
            
            print("Request Parameters:", request.parameters)

            callback(request)

        }
    }


    class func getGooglePlaces(searchText: String) -> APIRequest<JSON, Error> {
        let googleJson = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "config", withExtension: "json")!))
        let request: APIRequest<JSON, Error> = googleTron.swiftyJSON.request("json")
        request.method = .get
        request.parameters = [
            "strictbounds" : "",
            "location" : "42.4440,-76.5019",
            "radius" : 24140,
            "input" : searchText,
            "key" : googleJson["google-places"].stringValue
        ]
        return request
    }
    
    class func getBusLocations(_ directions: [Direction]) -> APIRequest<BusLocationResult, Error> {

        let request: APIRequest<BusLocationResult, Error> = mainTron.swiftyJSON.request("tracking")
        request.method = .post
        let departDirections = directions.filter { $0.type == .depart && $0.tripIdentifiers != nil }
        let dictionary = departDirections.map { (direction) -> [String : Any] in
            
            // The id of the location, or bus stop, the bus needs to get to
            let stopID = direction.startLocation.id
            
            return [
                "stopID"                :   stopID,
                "routeID"               :   String(direction.routeNumber),
                "tripIdentifiers"       :   direction.tripIdentifiers!
            ]
            
        }
        
        request.parameters = [ "data" : dictionary ]
        request.parameterEncoding = JSONEncoding.default
        return request
        
    }
    
    class func getDelay(tripId: String, stopId: String) -> APIRequest<JSON, Error> {
        let request: APIRequest<JSON, Error> = mainTron.swiftyJSON.request("delay")
        request.method = .get
        request.parameters = ["stopID": stopId, "tripID": tripId]
        // print("Delay request URL: \(source)/delay?stopID=\(request.parameters["stopID"]!)&tripID=\(request.parameters["tripID"]!)")
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
