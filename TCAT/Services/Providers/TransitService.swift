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
    func getAllStops() -> AnyPublisher<[Place], APIErrorHandler>
    func getAlerts() -> AnyPublisher<[ServiceAlert], APIErrorHandler>
    func getRoutes(start: Place, end: Place, time: Date, type: SearchType) -> AnyPublisher<RouteSectionsObject, APIErrorHandler>
    func getAppleSearchResults(searchText: String) -> AnyPublisher<AppleSearchResponse, APIErrorHandler>
    func updateApplePlacesCache(searchText: String, places: [Place]) -> AnyPublisher<Bool, APIErrorHandler>
    func getBusLocations(_ directions: [Direction]) -> AnyPublisher<BusLocation, APIErrorHandler>
    func getDelay(tripID: String, stopID: String) -> AnyPublisher<Int?, APIErrorHandler>
    func getAllDelays(trips: [Trip]) -> AnyPublisher<Delay, APIErrorHandler>
}

class TransitService: TransitServiceProtocol {

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getAllStops() -> AnyPublisher<[Place], APIErrorHandler> {
        let request = TransitProvider.allStops.makeRequest
        return networkManager.performRequest(request, decodingType: [Place].self)
    }

    func getAlerts() -> AnyPublisher<[ServiceAlert], APIErrorHandler> {
        let request = TransitProvider.alerts.makeRequest
        return networkManager.performRequest(request, decodingType: [ServiceAlert].self)
    }

    func getRoutes(start: Place, end: Place, time: Date, type: SearchType) -> AnyPublisher<RouteSectionsObject, APIErrorHandler> {
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
        return networkManager.performRequest(request, decodingType: RouteSectionsObject.self)
    }

    func getAppleSearchResults(searchText: String) -> AnyPublisher<AppleSearchResponse, APIErrorHandler> {
        let request = TransitProvider.appleSearch(searchText).makeRequest
        return networkManager.performRequest(request, decodingType: AppleSearchResponse.self)
    }

    func updateApplePlacesCache(searchText: String, places: [Place]) -> AnyPublisher<Bool, APIErrorHandler> {
        let body = ApplePlacesBody(query: searchText, places: places)
        let request = TransitProvider.applePlaces(body).makeRequest
        return networkManager.performRequest(request, decodingType: Bool.self)
    }

    func getBusLocations(_ directions: [Direction]) -> AnyPublisher<BusLocation, APIErrorHandler> {
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
        let request = TransitProvider.applePlaces(body).makeRequest
        return networkManager.performRequest(request, decodingType: BusLocation.self)
    }

    func getDelay(tripID: String, stopID: String) -> AnyPublisher<Int?, APIErrorHandler> {
        let body = GetDelayBody(stopID: stopID, tripID: tripID)
        let request = TransitProvider.delay(body).makeRequest
        return networkManager.performRequest(request, decodingType: Int?.self)
    }

    func getAllDelays(trips: [Trip]) -> AnyPublisher<Delay, APIErrorHandler> {
        let body = TripBody(data: trips)
        let request = TransitProvider.delay(body).makeRequest
        return networkManager.performRequest(request, decodingType: Delay.self)
    }

}
