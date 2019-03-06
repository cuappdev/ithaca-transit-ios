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
    
    /// Testing local servers for Network
    // Change `networkType` to `.local` to work locally.
    // Change `localIPAddress` to be the proper address
    
    static let networkType: NetworkType = .release
    static let apiVersion = "v1"

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
                         callback: @escaping (_ request: APIRequest<RoutesRequest, Error>) -> Void) {
        let request: APIRequest<RoutesRequest, Error> = tron.codable.request("route")
        request.method = .get
        request.parameters = [
            "arriveBy"          :   type == .arriveBy,
            "end"               :   "\(endCoord.latitude),\(endCoord.longitude)",
            "start"             :   "\(startCoord.latitude),\(startCoord.longitude)",
            "time"              :   time.timeIntervalSince1970,
            "destinationName"   :   endPlaceName,
            "originName"        :   startPlaceName
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


    class func getGooglePlacesAutocompleteResults(searchText: String) -> APIRequest<JSON, Error> {
        let request: APIRequest<JSON, Error> = tron.swiftyJSON.request("places")
        request.method = .post
        request.parameterEncoding = JSONEncoding.default
        request.parameters = ["query" : searchText]
        
        // Add unique identifier to request
        if let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) {
            request.parameters["uid"] = uid
        }
        
        return request
    }
    
    // MARK: #182 • To be updated with Route string identifier
    
    @discardableResult
    class func routeSelected(routeId: String) -> APIRequest<JSON, Error> {
        let request: APIRequest<JSON, Error> = tron.swiftyJSON.request("routeSelected")
        request.method = .post
        request.parameterEncoding = JSONEncoding.default
        request.parameters = ["routeId" : routeId]
        
        // Add unique identifier to request
        if let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) {
            request.parameters["uid"] = uid
        }
        
        return request
    }

    class func getBusLocations(_ directions: [Direction]) -> APIRequest<BusLocationRequest, Error> {
        let request: APIRequest<BusLocationRequest, Error> = tron.codable.request("tracking")
        request.method = .post
        let departDirections = directions.filter { $0.type == .depart && $0.tripIdentifiers != nil }
        let dictionary = departDirections.map { (direction) -> [String : Any] in

            // The id of the location, or bus stop, the bus needs to get to
            let stopID = direction.stops.first?.id ?? "-1"

            return [
                "stopID"                :   stopID,
                "routeID"               :   String(direction.routeNumber),
                "tripIdentifiers"       :   direction.tripIdentifiers!
            ]

        }

        request.parameters = ["data" : dictionary]
        request.parameterEncoding = JSONEncoding.default
        
        // Add unique identifier to request
        if let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) {
            request.parameters["uid"] = uid
        }
        
        return request
    }

    class func getDelay(tripId: String, stopId: String) -> APIRequest<BusDelayRequest, Error> {
        let request: APIRequest<BusDelayRequest, Error> = tron.codable.request("delay")
        request.method = .get
        request.parameters = [
            "stopID" : stopId,
            "tripID" : tripId
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
