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

class RouteSectionsObject: Codable {
    var fromStop: [Route]
    var boardingSoon: [Route]
    var walking: [Route]
}

internal struct DelayData: Codable {
    let tripId: String
    let stopId: String
}

internal struct GetDelayBody: Codable {
    var data: [DelayData]
}

struct DelayResponse: Decodable {
    let success: Bool
    let data: [DelayDataResponse]
}

struct DelayDataResponse: Decodable {
    let stopId: String
    let tripId: String
    let delay: Int?
}

//func toQueryItems() -> [URLQueryItem] {
//    return data.flatMap { delayData in
//        return [
//            URLQueryItem(name: "tripID", value: delayData.tripId),
//            URLQueryItem(name: "stopID", value: delayData.stopId)
//        ]
//    }
//}

//internal struct GetDelayBody: Codable {
//    
//    struct DelayData: Codable {
//        let tripId: String
//        let stopId: String
//    }
////    let stopID: String
////    let tripID: String
//    let data: [DelayData]
//    
//    func toQueryItems() -> [URLQueryItem] {
//            // Assuming you want to use the first entry in the data array
//            if let firstData = data.first {
//                return [
//                    URLQueryItem(name: "stopID", value: firstData.stopId),
//                    URLQueryItem(name: "tripID", value: firstData.tripId)
//                ]
//            }
//            return []
//        }
////    func toQueryItems() -> [URLQueryItem] {
////        return [URLQueryItem(name: "stopID", value: data.stopID), URLQueryItem(name: "tripID", value: data.tripID)]
////    }
//
//}

internal struct Trip: Codable {
    let stopID: String
    let tripID: String
}

internal struct TripBody: Codable {
    var data: [Trip]
}

internal struct Delay: Codable {
    let tripID: String
    let delay: Int?
}

struct APIResponse<T: Decodable>: Decodable {
    var success: Bool
    var data: T
}
