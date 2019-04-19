//
//  Network+Models.swift
//  TCAT
//
//  Created by Austin Astorga on 4/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

// MARK: Request Bodies
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
    let stopId: String
    let routeId: String
    let tripIdentifiers: [String]
}

internal struct GetDelayBody: Codable {
    let stopId: String
    let tripId: String
}

// MARK: Responses

struct Response<T: Codable>: Codable {

    var success: Bool
    var data: T

}

struct ChannelMessage: Codable {
    var ChannelId: Int
    var message: String
}

struct BusLocationRequest: Decodable {
    var success: Bool
    var data: [BusLocation]
}

struct BusDelayRequest: Codable {
    var success: Bool
    var data: Int?
}

struct SearchRequest: Codable {
    var success: Bool
    var data: [Place]
}

struct RoutesRequest: Codable {
    var success: Bool
    var data: [Route]
}
