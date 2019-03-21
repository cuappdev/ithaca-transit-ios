//
//  Network+Endpoints.swift
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

enum NetworkType: String {
    case local, debug, release
}

class Network {

    // MARK: Global Network Variables

    /// Testing local servers for Network
    // Change `networkType` to `.local` to work locally.
    // Change `localIPAddress` to be the proper address

    static let networkType: NetworkType = .release
    static let apiVersion = "v1"

    /// Used for local backend testing
    static let localIPAddress = "10.132.0.68"
    static let localSource = "http://\(localIPAddress):3000/api/\(apiVersion)/"

    /// Test server used for development
    static let debugIPAddress = "transit-testflight.cornellappdev.com"
    static let debugSource = "https://\(debugIPAddress)/api/\(apiVersion)/"

    /// Deployed server instance used for release
    static let releaseIPAddress = "transit-backend.cornellappdev.com"
    static let releaseSource = "https://\(releaseIPAddress)/api/\(apiVersion)/"

    /// Network IP address being used for specified networkType
    static var ipAddress: String {
        #if RELEASE
        if isTestFlight() {
           return debugIPAddress
        }
        #endif
        switch networkType {
        case .local: return localIPAddress
        case .debug: return debugIPAddress
        case .release: return releaseIPAddress
        }
    }

    /// Network source currently being used
    static var address: String {
        #if RELEASE
        if isTestFlight() {
            return debugSource
        }
        #endif
        switch networkType {
        case .local: return localSource
        case .debug: return debugSource
        case .release: return releaseSource
        }
    }

    static let tron = TRON(baseURL: Network.address)

    class func getAllStops() -> APIRequest<AllBusStopsRequest, Error> {
        let request: APIRequest<AllBusStopsRequest, Error> = tron.codable.request("allStops")
        request.method = .get
        return request
    }

    class func getAlerts() -> APIRequest<AlertRequest, Error> {
        let request: APIRequest<AlertRequest, Error> = tron.codable.request("alerts")
        request.method = .get
        return request
    }

    class func getRoutes(start: Place, end: Place, time: Date, type: SearchType,
                         callback: @escaping (_ request: APIRequest<RoutesRequest, Error>) -> Void) {
        
        let request: APIRequest<RoutesRequest, Error> = tron.codable.request("route")
        request.method = .get
        
        guard
            let startLat = start.latitude,
            let startLong = start.longitude,
            let endLat = end.latitude,
            let endLong = end.longitude
            else {
                print("[Network] getRoutes() No Valid Coordinates")
                callback(request)
                return
        }
        
        request.parameters = [
            "arriveBy"          :   type == .arriveBy,
            "end"               :   "\(endLat),\(endLong)",
            "start"             :   "\(startLat),\(startLong)",
            "time"              :   time.timeIntervalSince1970,
            "destinationName"   :   end.name,
            "originName"        :   start.name
        ]

        // Add unique identifier to request
        if let uid = sharedUserDefaults?.string(forKey: Constants.UserDefaults.uid) {
            request.parameters["uid"] = uid
        }

        callback(request)
    }
    
    class func getRequestURL(start: Place, end: Place, time: Date, type: SearchType) -> String {
        let path = "route"
        let arriveBy = (type == .arriveBy)
        let endStr = "\(String(describing: end.latitude)),\(String(describing: end.longitude))"
        let startStr =  "\(String(describing: start.latitude)),\(String(describing: start.longitude))"
        let time = time.timeIntervalSince1970
        
        return  "\(address)\(path)?arriveBy=\(arriveBy)&end=\(endStr)&start=\(startStr)&time=\(time)&destinationName=\(end.name)&originName=\(start.name)"
    }

    class func getMultiRoutes(startCoord: CLLocationCoordinate2D, time: Date, endCoords: [String], endPlaceNames: [String],
                              callback: @escaping (_ request: APIRequest<MultiRoutesRequest, Error>) -> Void) {
        let request: APIRequest<MultiRoutesRequest, Error> = tron.codable.request("multiroute")
        request.method = .get
        request.parameters = [
            "start": "\(startCoord.latitude),\(startCoord.longitude)",
            "time": time.timeIntervalSince1970,
            "end": endCoords,
            "destinationNames": endPlaceNames
        ]

        callback(request)
    }

    class func getSearchResults(searchText: String) -> APIRequest<SearchRequest, Error> {
        let request: APIRequest<SearchRequest, Error> = tron.codable.request("search")
        request.method = .post
        request.parameterEncoding = JSONEncoding.default
        request.parameters = [
            "query": searchText
        ]
        return request
    }

    @discardableResult
    class func routeSelected(routeId: String) -> APIRequest<JSON, Error> {
        let request: APIRequest<JSON, Error> = tron.swiftyJSON.request("routeSelected")
        request.method = .post
        request.parameterEncoding = JSONEncoding.default
        request.parameters = ["routeId" : routeId]
        
        // Add unique identifier to request
        if let uid = sharedUserDefaults?.string(forKey: Constants.UserDefaults.uid) {
            request.parameters["uid"] = uid
        }
        
        return request
    }

    class func getBusLocations(_ directions: [Direction]) -> APIRequest<BusLocationRequest, Error> {
        let request: APIRequest<BusLocationRequest, Error> = tron.codable.request("tracking")
        request.method = .post
        let departDirections = directions.filter { $0.type == .depart && $0.tripIdentifiers != nil }
        let dictionary = departDirections.map { (direction) -> [String: Any] in

            // The id of the location, or bus stop, the bus needs to get to

            let stopID = direction.stops.first?.id ?? "-1"

            return [
                "stopID": stopID,
                "routeID": String(direction.routeNumber),
                "tripIdentifiers": direction.tripIdentifiers!
            ]

        }

        request.parameters = [ "data": dictionary ]
        request.parameterEncoding = JSONEncoding.default
        return request
    }

    class func getDelay(tripId: String, stopId: String) -> APIRequest<BusDelayRequest, Error> {
        let request: APIRequest<BusDelayRequest, Error> = tron.codable.request("delay")
        request.method = .get
        request.parameters = ["stopID": stopId, "tripID": tripId]

        return request
    }

    class func getDelayUrl(tripId: String, stopId: String) -> String {
        let path = "delay"

        return "\(address)\(path)?stopID=\(stopId)&tripID=\(tripId)"
    }

}
