//
//  Network.swift
//  TCAT
//
//  Created by Austin Astorga on 4/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation
import GooglePlaces
import SwiftyJSON
import TRON

enum NetworkType: String {
    case local, debug, release
}

class Network {

    // MARK: Global Network Variables

    /// Testing local servers for Network
    // Change `networkType` to `.local` to work locally.
    // Change `localIPAddress` to be the proper address

    static let apiVersion = "v1"
    static let networkType: NetworkType = .release

    /// Used for local backend testing
    static let localIPAddress = "10.132.0.68"
    static let localSource = "http://\(localIPAddress):3000/api/\(apiVersion)/"

    /// Test server used for development
    static let debugIPAddress = "34.238.157.63"
    static let debugSource = "http://\(debugIPAddress)/api/\(apiVersion)/"

    /// Deployed server instance used for release
    static let releaseIPAddress = "transit-backend.cornellappdev.com"
    static let releaseSource = "http://\(releaseIPAddress)/api/\(apiVersion)/"

    /// Network IP address being used for specified networkType
    static var ipAddress: String {
        switch networkType {
        case .debug: return debugIPAddress
        case .local: return localIPAddress
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

    static let tron = TRON(baseURL: Network.address)

    class func getAllStops() -> APIRequest<AllBusStops, Error> {
        let request: APIRequest<AllBusStops, Error> = tron.swiftyJSON.request("allStops")
        request.method = .get
        return request
    }

    class func getCoordinates(start: CoordinateAcceptor, end: CoordinateAcceptor,
                              callback: @escaping (_ startCoord: CLLocationCoordinate2D?, _ endCoord: CLLocationCoordinate2D?, _ error: CoordinateVisitorError?) -> Void ) {

        let visitor = CoordinateVisitor()

        start.accept(visitor: visitor) { (startCoord, error) in

            guard let startCoord = startCoord else {
                callback(nil, nil, error)
                return
            }

            end.accept(visitor: visitor) { (endCoord, error) in

                guard let endCoord = endCoord else {
                    callback(nil, nil, error)
                    return
                }

                callback(startCoord, endCoord, nil)

            }

        }

    }

    class func getRoutes(startCoord: CLLocationCoordinate2D, endCoord: CLLocationCoordinate2D, startPlaceName: String, endPlaceName: String, time: Date, type: SearchType,
                         callback: @escaping (_ request: APIRequest<JSON, Error>) -> Void) {

        let request: APIRequest<JSON, Error> = tron.swiftyJSON.request("route")
        request.method = .get
        request.parameters = [
            "arriveBy": type == .arriveBy,
            "end": "\(endCoord.latitude),\(endCoord.longitude)",
            "start": "\(startCoord.latitude),\(startCoord.longitude)",
            "time": time.timeIntervalSince1970,
            "destinationName": endPlaceName,
            "originName": startPlaceName
        ]

        // Add unique identifier to request
        if let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) {
            request.parameters["uid"] = uid
        }

        callback(request)
    }

    class func getRequestUrl(startCoord: CLLocationCoordinate2D, endCoord: CLLocationCoordinate2D,
                             originName: String, destinationName: String, time: Date, type: SearchType) -> String {
        let path = "route"
        let arriveBy = (type == .arriveBy)
        let end = "\(endCoord.latitude),\(endCoord.longitude)"
        let start =  "\(startCoord.latitude),\(startCoord.longitude)"
        let time = time.timeIntervalSince1970

        return  "\(address)\(path)?arriveBy=\(arriveBy)&end=\(end)&start=\(start)&time=\(time)&destinationName=\(destinationName)&originName=\(originName)"
    }

    class func getMultiRoutes(startCoord: CLLocationCoordinate2D, time: Date, endCoords: [String], endPlaceNames: [String],
                              callback: @escaping (_ request: APIRequest<JSON, Error>) -> Void) {
        let request: APIRequest<JSON, Error> = tron.swiftyJSON.request("multiroute")
        request.method = .get
        request.parameters = [
            "start": "\(startCoord.latitude),\(startCoord.longitude)",
            "time": time.timeIntervalSince1970,
            "end": endCoords,
            "destinationNames": endPlaceNames
        ]

        callback(request)
    }

    class func getGooglePlacesAutocompleteResults(searchText: String) -> APIRequest<JSON, Error> {
        let request: APIRequest<JSON, Error> = tron.swiftyJSON.request("places")
        request.method = .post
        request.parameterEncoding = JSONEncoding.default
        request.parameters = ["query": searchText]

        // Add unique identifier to request
        if let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) {
            request.parameters["uid"] = uid
        }

        return request
    }

    // MARK: #182 • To be updated with Route string identifier

    @discardableResult
    class func routeSelected(url: String, rowIndex: Int) -> APIRequest<JSON, Error> {
        let request: APIRequest<JSON, Error> = tron.swiftyJSON.request("routeSelected")
        request.method = .post
        request.parameterEncoding = JSONEncoding.default
        request.parameters = [
            "tripId": url,
            "rowIndex": rowIndex
        ]

        // Add unique identifier to request
        if let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) {
            request.parameters["uid"] = uid
        }

        return request
    }

    class func getBusLocations(_ directions: [Direction]) -> APIRequest<BusLocationResult, Error> {

        let request: APIRequest<BusLocationResult, Error> = tron.swiftyJSON.request("tracking")
        request.method = .post
        let departDirections = directions.filter { $0.type == .depart && $0.tripIdentifiers != nil }
        let dictionary = departDirections.map { (direction) -> [String: Any] in

            // The id of the location, or bus stop, the bus needs to get to
            let stopID = direction.startLocation.id

            return [
                "stopID": stopID,
                "routeID": String(direction.routeNumber),
                "tripIdentifiers": direction.tripIdentifiers!
            ]

        }

        request.parameters = ["data": dictionary]
        request.parameterEncoding = JSONEncoding.default

        // Add unique identifier to request
        if let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) {
            request.parameters["uid"] = uid
        }

        return request

    }

    class func getDelay(tripId: String, stopId: String) -> APIRequest<JSON, Error> {
        let request: APIRequest<JSON, Error> = tron.swiftyJSON.request("delay")
        request.method = .get
        request.parameters = [
            "stopID": stopId,
            "tripID": tripId
        ]

        // Add unique identifier to request
        if let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) {
            request.parameters["uid"] = uid
        }

        return request
    }

    class func getDelayUrl(tripId: String, stopId: String) -> String {
        let path = "delay"
        return "\(address)\(path)?stopID=\(stopId)&tripID=\(tripId)"
    }

}

class Error: JSONDecodable {
    required init(json: JSON) {}
}

class AllBusStops: JSONDecodable {
    var allStops: [BusStop] = [BusStop]()

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

        var nonDuplicateStops = crossReference.filter {$1.count == 1}.map { (_, value) -> BusStop in
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
