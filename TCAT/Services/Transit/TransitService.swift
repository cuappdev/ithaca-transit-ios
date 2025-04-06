//
//  Services.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/16/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation
import Combine

/// Protocol defining the methods for accessing transit-related services, including fetching delays, stops, alerts, and more.
protocol TransitServiceProtocol: AnyObject {

    /// Retrieves delay information for the specified trips, refreshing at regular intervals.
    /// - Parameters:
    ///   - trips: An array of `Trip` objects representing the trips for which delay data is required.
    ///   - refreshInterval: The time interval (in seconds) between data refreshes.
    /// - Returns: A publisher that emits an array of `Delay` objects on success, or an `ApiErrorHandler` on failure.
    func getAllDelays(trips: [Trip], refreshInterval: TimeInterval) -> AnyPublisher<[Delay], ApiErrorHandler>

    /// Retrieves all transit stops available.
    /// - Returns: A publisher that emits an array of `Place` objects representing stops, or an `ApiErrorHandler` on failure.
    func getAllStops() -> AnyPublisher<[Place], ApiErrorHandler>

    /// Fetches active service alerts for transit services.
    /// - Returns: A publisher that emits an array of `ServiceAlert` objects, or an `ApiErrorHandler` if unable to retrieve alerts.
    func getAlerts() -> AnyPublisher<[ServiceAlert], ApiErrorHandler>

    /// Searches for Apple places based on the provided text query.
    /// - Parameter searchText: The text used to query Apple's location services.
    /// - Returns: A publisher that emits an `AppleSearchResponse` object containing the results or an `ApiErrorHandler` on failure.
    func getAppleSearchResults(searchText: String) -> AnyPublisher<AppleSearchResponse, ApiErrorHandler>

    /// Retrieves real-time bus locations for the specified directions, refreshing at a defined interval.
    /// - Parameters:
    ///   - directions: An array of `Direction` objects to track bus locations.
    ///   - refreshInterval: The time interval (in seconds) between data refreshes. Default is 5.0 seconds.
    /// - Returns: A publisher emitting an array of `BusLocation` objects or an `ApiErrorHandler`.
    func getBusLocations(_ directions: [Direction], refreshInterval: TimeInterval) -> AnyPublisher<[BusLocation], ApiErrorHandler>

    /// Retrieves the delay time for a specific trip and stop at set intervals.
    /// - Parameters:
    ///   - tripID: Unique identifier of the trip.
    ///   - stopID: Unique identifier of the stop.
    ///   - refreshInterval: Time interval (in seconds) for data refreshes. Default is 10.0 seconds.
    /// - Returns: A publisher emitting an optional `Int` delay (in seconds), or an `ApiErrorHandler` if retrieval fails.
    func getDelay(tripID: String, stopID: String, refreshInterval: TimeInterval) -> AnyPublisher<Int?, ApiErrorHandler>

    /// Finds available transit routes between the specified start and end locations for a given time.
    /// - Parameters:
    ///   - start: The starting `Place` for the route.
    ///   - end: The destination `Place` for the route.
    ///   - time: The desired time of travel.
    ///   - type: Specifies whether the time is for arrival or departure.
    /// - Returns: A publisher emitting a `RouteSectionsObject` with route details or an `ApiErrorHandler` on error.
    func getRoutes(start: Place, end: Place, time: Date, type: SearchType) -> AnyPublisher<RouteSectionsObject, ApiErrorHandler>

    /// Subscribes to delay notification for a specific trip's arrival
    /// The notification is sent when there is a change in the delay.
    /// - Parameters:
    ///   - deviceToken: The FCM token for the device
    ///   - stopID: The stop ID to monitor
    ///   - tripID: The trip ID to monitor
    ///   - uid: The unique identifier for the user
    /// - Returns: A publisher that emits Bool on success, or an ApiErrorHandler on failure
    func subscribeToDelayNotifications(
        deviceToken: String,
        stopID: String?,
        tripID: String,
        uid: String
    ) -> AnyPublisher<Bool, ApiErrorHandler>

    /// Subscribes to departure notifications for a specific trip
    /// - Parameters:
    ///   - deviceToken: The FCM token for the device
    ///   - startTime: The timestamp to start monitoring from
    ///   - uid: The unique identifier for the user
    /// - Returns: A publisher that emits Bool on success, or an ApiErrorHandler on failure
    func subscribeToDepartureNotifications(
        deviceToken: String,
        startTime: String,
        uid: String
    ) -> AnyPublisher<Bool, ApiErrorHandler>

    func unsubscribeFromDelayNotifications(deviceToken: String, stopID: String?, tripID: String, uid: String) -> AnyPublisher<Bool, ApiErrorHandler>

    func unsubscribeFromDepartureNotifications(deviceToken: String, startTime: String, uid: String) -> AnyPublisher<Bool, ApiErrorHandler>

    /// Updates the local cache of Apple places based on the search text and provided locations.
    /// - Parameters:
    ///   - searchText: The query text used for retrieving places.
    ///   - places: Array of `Place` objects to cache.
    /// - Returns: A publisher emitting `true` if successful, or an `ApiErrorHandler` if the update fails.
    func updateApplePlacesCache(searchText: String, places: [Place]) -> AnyPublisher<Bool, ApiErrorHandler>
}

/// Service implementing `TransitServiceProtocol` to fetch and manage transit-related data.
class TransitService: TransitServiceProtocol {

    // Singleton instance
    static var shared = TransitService(networkManager: NetworkManager())

    /// Manages network requests for transit services.
    private let networkManager: NetworkManager

    // Initializer
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    // MARK: - Protocol Methods

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
        let locationsInfo = departDirections.compactMap { direction -> BusLocationsInfo? in
            let stopId = direction.stops.first?.id ?? "-1"
            guard let tripId = direction.tripIdentifiers?.first else { return nil }
            return BusLocationsInfo(
                stopId: stopId,
                routeId: String(direction.routeNumber),
                tripId: tripId
            )
        }
        
        // Usable for buses that actually have live tracking
        let debugLocationsInfo: [BusLocationsInfo] = [
            BusLocationsInfo(stopId: "3593", routeId: "30", tripId: "t3FC-b3ED-slC")
        ]

        let body = GetBusLocationsBody(data: locationsInfo)
        print("get bus locations body: \(body)")

        let request = TransitProvider.busLocations(body).makeRequest
        print("get bus locations request: \(request)")

        return Timer.publish(every: refreshInterval, on: .main, in: .default)
            .autoconnect()
            .flatMap { _ in
                self.networkManager.requestResponse(request)
                    .handleEvents(receiveOutput: { data in
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("raw api response \(responseString)")
                        } else {
                            print("error in printing api response")
                        }
                    }, receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("network error \(error)")
                        }
                    })
                    .decode(type: BusLocationResponse.self, decoder: JSONDecoder())
                    .map(\.data)
                    .mapError { error in
                        print("mapping error \(error)")
                        return ApiErrorHandler(error: error)
                    }
                    .catch { error in
                        Just<[BusLocation]>([])
                            .setFailureType(to: ApiErrorHandler.self)
                    }
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
        let uid = userDefaults.string(forKey: Constants.UserDefaults.uid)
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

    func subscribeToDelayNotifications(
        deviceToken: String,
        stopID: String?,
        tripID: String,
        uid: String
    ) -> AnyPublisher<Bool, ApiErrorHandler> {
        let body = DelayNotificationBody(deviceToken: deviceToken, stopID: stopID, tripID: tripID, uid: uid)
        let request = TransitProvider.delayNotification(body).makeRequest
        return networkManager.request(request, decodingType: Bool.self, responseType: .simple)
    }

    func subscribeToDepartureNotifications(
        deviceToken: String,
        startTime: String,
        uid: String
    ) -> AnyPublisher<Bool, ApiErrorHandler> {
        print("startTime: \(startTime)")
        let body = DepartureNotificationBody(deviceToken: deviceToken, startTime: startTime, uid: uid)
        let request = TransitProvider.departureNotification(body).makeRequest
        return networkManager.request(request, decodingType: Bool.self, responseType: .simple)
    }

    func unsubscribeFromDelayNotifications(
        deviceToken: String,
        stopID: String?,
        tripID: String,
        uid: String
    ) -> AnyPublisher<Bool, ApiErrorHandler> {
        let body = DelayNotificationBody(deviceToken: deviceToken, stopID: stopID, tripID: tripID, uid: uid)
        let request = TransitProvider.cancelDelayNotification(body).makeRequest
        return networkManager.request(request, decodingType: Bool.self, responseType: .simple)
    }

    func unsubscribeFromDepartureNotifications(
        deviceToken: String,
        startTime: String,
        uid: String
    ) -> AnyPublisher<Bool, ApiErrorHandler> {
        let body = DepartureNotificationBody(deviceToken: deviceToken, startTime: startTime, uid: uid)
        let request = TransitProvider.cancelDepartureNotification(body).makeRequest
        return networkManager.request(request, decodingType: Bool.self, responseType: .simple)
    }

    func updateApplePlacesCache(searchText: String, places: [Place]) -> AnyPublisher<Bool, ApiErrorHandler> {
        let body = ApplePlacesBody(query: searchText, places: places)
        let request = TransitProvider.applePlaces(body).makeRequest
        return networkManager.request(request, decodingType: Bool.self)
    }
}
