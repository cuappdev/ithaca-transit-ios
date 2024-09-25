//
//  Network+Endpoints.swift
//  TCAT
//
//  Created by Austin Astorga on 4/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import Foundation
import FutureNova

extension Endpoint {

    static func setupEndpointConfig() {
        Endpoint.config.scheme = "https"
        Endpoint.config.host = TransitEnvironment.transitURL.replacingOccurrences(of: "https://", with: "")
        Endpoint.config.commonPath = "/api/v3"
    }

    static func getAllStops() -> Endpoint {
        return Endpoint(path: Constants.Endpoints.allStops)
    }

    static func getAlerts() -> Endpoint {
        return Endpoint(path: Constants.Endpoints.alerts)
    }

    static func getRoutes(
        start: Place,
        end: Place,
        time: Date,
        type: SearchType
    ) -> Endpoint? {
        let uid = sharedUserDefaults?.string(forKey: Constants.UserDefaults.uid)
        let body = GetRoutesBody(
            arriveBy: type == .arriveBy,
            end: "\(end.latitude),\(end.longitude)",
            start: "\(start.latitude),\(start.longitude)",
            time: time.timeIntervalSince1970,
            destinationName: end.name,
            originName: start.name,
            uid: uid
        )
        // MARK: - Temporary fix for Boom
        return Endpoint(path: "/api/v2"+Constants.Endpoints.getRoutes, body: body, useCommonPath: false)
    }

    static func getAppleSearchResults(searchText: String) -> Endpoint {
        let body = SearchResultsBody(query: searchText)
        return Endpoint(path: Constants.Endpoints.appleSearch, body: body)
    }

    static func updateApplePlacesCache(searchText: String, places: [Place]) -> Endpoint {
        let body = ApplePlacesBody(query: searchText, places: places)
        return Endpoint(path: Constants.Endpoints.applePlaces, body: body)
    }

    static func getBusLocations(_ directions: [Direction]) -> Endpoint {
        let departDirections = directions.filter { $0.type == .depart && $0.tripIdentifiers != nil }

        let locationsInfo = departDirections.map { direction -> BusLocationsInfo in
            // The id of the location, or bus stop, the bus needs to get to
            let stopID = direction.stops.first?.id ?? "-1"
            return BusLocationsInfo(
                stopID: stopID,
                routeID: String(direction.routeNumber),
                tripIdentifiers: direction.tripIdentifiers!
            )
        }

        let body = GetBusLocationsBody(data: locationsInfo)
        return Endpoint(path: Constants.Endpoints.busLocations, body: body)
    }

    static func getDelay(tripID: String, stopID: String) -> Endpoint {
        let queryItems = GetDelayBody(stopID: stopID, tripID: tripID).toQueryItems()
        return Endpoint(path: Constants.Endpoints.delay, queryItems: queryItems)
    }

    static func getAllDelays(trips: [Trip]) -> Endpoint {
        let body = TripBody(data: trips)
        return Endpoint(path: Constants.Endpoints.delays, body: body)
    }

}
