//
//  Network+Endpoints.swift
//  TCAT
//
//  Created by Austin Astorga on 4/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import CoreLocation
import FutureNova

extension Endpoint {

    static func getAllStops() -> Endpoint {
        return Endpoint(path: Constants.Endpoints.allStops)
    }

//    class func getAllStops() -> APIRequest<AllBusStopsRequest, Error> {
//        let request: APIRequest<AllBusStopsRequest, Error> = tron.codable.request("allStops")
//        request.method = .get
//        return request
//    }

    static func getAlerts() -> Endpoint {
        return Endpoint(path: Constants.Endpoints.alerts)
    }

//    class func getAlerts() -> APIRequest<AlertRequest, Error> {
//        let request: APIRequest<AlertRequest, Error> = tron.codable.request("alerts")
//        request.method = .get
//        return request
//    }

    static func getRoutes(start: Place,
                          end: Place,
                          time: Date,
                          type: SearchType) -> Endpoint? {
        guard
            let startLat = start.latitude,
            let startLong = start.longitude,
            let endLat = end.latitude,
            let endLong = end.longitude
            else {
                print("[Network] getRoutes() No Valid Coordinates")
                return nil
        }
        let uid = sharedUserDefaults?.string(forKey: Constants.UserDefaults.uid)
        let body = GetRoutesBody(arriveBy: type == .arriveBy, end: "\(endLat),\(endLong)", start: "\(startLat),\(startLong)", time: time.timeIntervalSince1970, destinationName: end.name, originName: start.name, uid: uid)

        return Endpoint(path: Constants.Endpoints.getRoutes, body: body)
    }

//    class func getRoutes(start: Place, end: Place, time: Date, type: SearchType,
//                         callback: @escaping (_ request: APIRequest<RoutesRequest, Error>) -> Void) {
//
//        let request: APIRequest<RoutesRequest, Error> = tron.codable.request("route")
//        request.method = .get
//
//
//
//        request.parameters = [
//            "arriveBy": type == .arriveBy,
//            "end": "\(endLat),\(endLong)",
//            "start": "\(startLat),\(startLong)",
//            "time": time.timeIntervalSince1970,
//            "destinationName": end.name,
//            "originName": start.name
//        ]
//
//        // Add unique identifier to request
//        if let uid = sharedUserDefaults?.string(forKey: Constants.UserDefaults.uid) {
//            request.parameters["uid"] = uid
//        }
//
//        callback(request)
//    }

    static func getRequestURL(start: Place,
                              end: Place,
                              time: Date,
                              type: SearchType) -> String {
        let path = "route"
        let arriveBy = (type == .arriveBy)
        let endStr = "\(String(describing: end.latitude)),\(String(describing: end.longitude))"
        let startStr =  "\(String(describing: start.latitude)),\(String(describing: start.longitude))"
        let time = time.timeIntervalSince1970

        return  "\(String(describing: Endpoint.config.host))\(path)?arriveBy=\(arriveBy)&end=\(endStr)&start=\(startStr)&time=\(time)&destinationName=\(end.name)&originName=\(start.name)"
    }

    static func getMultiRoutes(startCoord: CLLocationCoordinate2D,
                               time: Date,
                               endCoords: [String],
                               endPlaceNames: [String]) -> Endpoint {
        let body = MultiRoutesBody(start: "\(startCoord.latitude),\(startCoord.longitude)", time: time.timeIntervalSince1970, end: endCoords, destinationNames: endPlaceNames)
        return Endpoint(path: Constants.Endpoints.multiRoute, body: body)

    }

//    class func getMultiRoutes(startCoord: CLLocationCoordinate2D, time: Date, endCoords: [String], endPlaceNames: [String],
//                              callback: @escaping (_ request: APIRequest<MultiRoutesRequest, Error>) -> Void) {
//        let request: APIRequest<MultiRoutesRequest, Error> = tron.codable.request("multiroute")
//        request.method = .get
//        request.parameters = [
//            "start": "\(startCoord.latitude),\(startCoord.longitude)",
//            "time": time.timeIntervalSince1970,
//            "end": endCoords,
//            "destinationNames": endPlaceNames
//        ]
//
//        callback(request)
//    }

    static func getSearchResults(searchText: String) -> Endpoint {
        let body = SearchResultsBody(query: searchText)
        return Endpoint(path: Constants.Endpoints.searchResults, body: body)
    }

//    class func getSearchResults(searchText: String) -> APIRequest<SearchRequest, Error> {
//        let request: APIRequest<SearchRequest, Error> = tron.codable.request("search")
//        request.method = .post
//        request.parameterEncoding = JSONEncoding.default
//        request.parameters = [
//            "query": searchText
//        ]
//        return request
//    }

    static func routeSelected(routeId: String) -> Endpoint {
        // Add unique identifier to request
        let uid = sharedUserDefaults?.string(forKey: Constants.UserDefaults.uid)

        let body = RouteSelectedBody(routeId: routeId, uid: uid)
        return Endpoint(path: Constants.Endpoints.routeSelected, body: body)
    }
//    class func routeSelected(routeId: String) -> APIRequest<JSON, Error> {
//        let request: APIRequest<JSON, Error> = tron.codable.request("routeSelected")
//        request.method = .post
//        request.parameterEncoding = JSONEncoding.default
//        request.parameters = ["routeId": routeId]
//
//        // Add unique identifier to request
//        if let uid = sharedUserDefaults?.string(forKey: Constants.UserDefaults.uid) {
//            request.parameters["uid"] = uid
//        }
//
//        return request
//    }

    static func getBusLocations(_ directions: [Direction]) -> Endpoint {
        let departDirections = directions.filter { $0.type == .depart && $0.tripIdentifiers != nil }

        var locationsInfo: [BusLocationsInfo] = []
        for direction in departDirections {
            // The id of the location, or bus stop, the bus needs to get to

            let stopID = direction.stops.first?.id ?? "-1"
            locationsInfo.append(BusLocationsInfo(stopId: stopID, routeId: String(direction.routeNumber), tripIdentifiers: direction.tripIdentifiers!))
        }

        let body = GetBusLocationsBody(data: locationsInfo)
        return Endpoint(path: Constants.Endpoints.busLocations, body: body)
    }

//    class func getBusLocations(_ directions: [Direction]) -> APIRequest<BusLocationRequest, Error> {
//        let request: APIRequest<BusLocationRequest, Error> = tron.codable.request("tracking")
//        request.method = .post
//        let departDirections = directions.filter { $0.type == .depart && $0.tripIdentifiers != nil }
//        let dictionary = departDirections.map { (direction) -> [String: Any] in
//
//            // The id of the location, or bus stop, the bus needs to get to
//
//            let stopID = direction.stops.first?.id ?? "-1"
//
//            return [
//                "stopID": stopID,
//                "routeID": String(direction.routeNumber),
//                "tripIdentifiers": direction.tripIdentifiers!
//            ]
//
//        }
//
//        request.parameters = [ "data": dictionary ]
//        request.parameterEncoding = JSONEncoding.default
//        return request
//    }

    static func getDelay(tripId: String, stopId: String) -> Endpoint {
        let body = GetDelayBody(stopId: stopId, tripId: tripId)
        return Endpoint(path: Constants.Endpoints.delay, body: body)
    }

//    class func getDelay(tripId: String, stopId: String) -> APIRequest<BusDelayRequest, Error> {
//        let request: APIRequest<BusDelayRequest, Error> = tron.codable.request("delay")
//        request.method = .get
//        request.parameters = ["stopID": stopId, "tripID": tripId]
//
//        return request
//    }

    static func getDelayUrl(tripId: String, stopId: String) -> String {
        let path = "delay"

        return "\(String(describing: Endpoint.config.host))\(path)?stopID=\(stopId)&tripID=\(tripId)"
    }

}
