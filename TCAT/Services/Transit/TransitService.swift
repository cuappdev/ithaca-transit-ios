//
//  Services.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/16/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation
import Combine

protocol TransitServiceProtocol: AnyObject {
    func getAllDelays(trips: [Trip], refreshInterval: TimeInterval) -> AnyPublisher<[Delay], ApiErrorHandler>
    func getAllStops() -> AnyPublisher<[Place], ApiErrorHandler>
    func getAlerts() -> AnyPublisher<[ServiceAlert], ApiErrorHandler>
    func getAppleSearchResults(searchText: String) -> AnyPublisher<AppleSearchResponse, ApiErrorHandler>
    func getBusLocations(
        _ directions: [Direction],
        refreshInterval: TimeInterval
    ) -> AnyPublisher<
        [BusLocation],
        ApiErrorHandler
    >
    func getDelay(tripID: String, stopID: String, refreshInterval: TimeInterval) -> AnyPublisher<Int?, ApiErrorHandler>
    func getRoutes(
        start: Place,
        end: Place,
        time: Date,
        type: SearchType
    ) -> AnyPublisher<
        RouteSectionsObject,
        ApiErrorHandler
    >
    func updateApplePlacesCache(searchText: String, places: [Place]) -> AnyPublisher<Bool, ApiErrorHandler>

}

// MARK: - TransitService Implementation

class TransitService: TransitServiceProtocol {

    // Singleton instance
    static var shared = TransitService(networkManager: NetworkManager())

    // Network manager instance
    private let networkManager: NetworkManager

    // Initializer
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getAllDelays(trips: [Trip], refreshInterval: TimeInterval = 10.0) -> AnyPublisher<[Delay], ApiErrorHandler> {
        let body = TripBody(data: trips)
        let request = TransitProvider.allDelays(body).makeRequest

        return Timer.publish(every: refreshInterval, on: .main, in: .default)
            .autoconnect()
            .flatMap { _ in
                self.networkManager.request(request, decodingType: [Delay].self)
            }
            .eraseToAnyPublisher()
    }

    func getAllStops() -> AnyPublisher<[Place], ApiErrorHandler> {
        let request = TransitProvider.allStops.makeRequest
        return networkManager.request(request, decodingType: [Place].self)
    }

    func getAlerts() -> AnyPublisher<[ServiceAlert], ApiErrorHandler> {
        let request = TransitProvider.alerts.makeRequest
        return networkManager.request(request, decodingType: [ServiceAlert].self)
    }

    func getAppleSearchResults(searchText: String) -> AnyPublisher<AppleSearchResponse, ApiErrorHandler> {
        let body = SearchResultsBody(query: searchText)
        let request = TransitProvider.appleSearch(body).makeRequest
        return networkManager.request(request, decodingType: AppleSearchResponse.self)
    }

    func getBusLocations(
        _ directions: [Direction],
        refreshInterval: TimeInterval = 5.0
    ) -> AnyPublisher<
        [BusLocation],
        ApiErrorHandler
    > {
        let departDirections = directions.filter { $0.type == .depart && $0.tripIdentifiers != nil }

        let locationsInfo = departDirections.map { direction -> BusLocationsInfo in
            let stopID = direction.stops.first?.id ?? "-1"
            return BusLocationsInfo(
                stopID: stopID,
                routeID: String(direction.routeNumber),
                tripIdentifiers: direction.tripIdentifiers!
            )
        }

        let body = GetBusLocationsBody(data: locationsInfo)
        let request = TransitProvider.busLocations(body).makeRequest

        return Timer.publish(every: refreshInterval, on: .main, in: .default)
            .autoconnect()
            .flatMap { _ in
                self.networkManager.request(request, decodingType: [BusLocation].self)
            }
            .eraseToAnyPublisher()
    }

    func getDelay(
        tripID: String,
        stopID: String,
        refreshInterval: TimeInterval = 10.0
    ) -> AnyPublisher<
        Int?,
        ApiErrorHandler
    > {
        let body = GetDelayBody(stopID: stopID, tripID: tripID)
        let request = TransitProvider.delay(body).makeRequest

        return Timer.publish(every: refreshInterval, on: .main, in: .default)
            .autoconnect()
            .flatMap { _ in
                self.networkManager.request(request, decodingType: Int?.self)
            }
            .eraseToAnyPublisher()
    }

    func getRoutes(
        start: Place,
        end: Place,
        time: Date,
        type: SearchType
    ) -> AnyPublisher<
        RouteSectionsObject,
        ApiErrorHandler
    > {
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
        let request = TransitProvider.routes(body).makeRequest
        return networkManager.request(request, decodingType: RouteSectionsObject.self)
    }

    func updateApplePlacesCache(searchText: String, places: [Place]) -> AnyPublisher<Bool, ApiErrorHandler> {
        let body = ApplePlacesBody(query: searchText, places: places)
        let request = TransitProvider.applePlaces(body).makeRequest
        return networkManager.request(request, decodingType: Bool.self)
    }
}
