//
//  Network+Models.swift
//  TCAT
//
//  Created by Austin Astorga on 4/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import Foundation
import SwiftyJSON

// MARK: - Request Bodies
internal struct ApplePlacesBody: Codable {
    let query: String
    let places: [Place]
}

internal struct GetRoutesBody: Codable {
    let arriveBy: Bool
    let end: String
    let start: String
    let time: Double
    let destinationName: String
    let originName: String
    let uid: String?
}

internal struct MultiRoutesBody: Codable {
    let start: String
    let time: Double
    let end: [String]
    let destinationNames: [String]
}

internal struct PlaceIDCoordinatesBody: Codable {
    let placeID: String
}

internal struct SearchResultsBody: Codable {
    let query: String
}

internal struct RouteSelectedBody: Codable {
    let routeId: String
    let uid: String?
}

internal struct GetBusLocationsBody: Codable {
    var data: [BusLocationsInfo]
}

internal struct BusLocationsInfo: Codable {
    let stopID: String
    let routeID: String
    let tripIdentifiers: [String]
}

internal struct GetDelayBody: Codable {

    let stopID: String
    let tripID: String

    func toQueryItems() -> [URLQueryItem] {
        return [URLQueryItem(name: "stopID", value: stopID), URLQueryItem(name: "tripID", value: tripID)]
    }

}

internal struct Trip: Codable {
    let stopID: String
    let tripID: String
}

internal struct TripBody: Codable {
    var data: [Trip]
}

internal struct DelayNotificationBody: Codable {
    let deviceToken: String
    let stopID: String?
    let tripID: String
    let uid: String
}


internal struct DepartureNotificationBody: Codable {
    let deviceToken: String
    let startTime: String
    let uid: String
}


struct APIResponse<T: Decodable>: Decodable {
    var success: Bool
    var data: T
}

struct SimpleAPIResponse: Decodable {
    var success: Bool
}
