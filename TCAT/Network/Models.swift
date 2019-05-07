//
//  Network+Models.swift
//  TCAT
//
//  Created by Austin Astorga on 4/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON
import TRON
import CoreLocation

struct Error: JSONDecodable, Codable {
    init(json: JSON) {}

    var error: String!
}

struct AlertRequest: Codable {
    let success: Bool
    let data: [Alert]
}

struct Alert: Codable {
    var id: Int
    var message: String
    var fromDate: String
    var toDate: String
    var fromTime: String
    var toTime: String
    var priority: Int
    var daysOfWeek: String
    var routes: [Int]
    var signs: [Int]
    var channelMessages: [ChannelMessage]

    init(id: Int,
         message: String,
         fromDate: String,
         toDate: String,
         fromTime: String,
         toTime: String,
         priority: Int,
         daysOfWeek: String,
         routes: [Int],
         signs: [Int],
         channelMessages: [ChannelMessage]) {

        self.id = id
        self.message = message
        self.fromDate = fromDate
        self.toDate = toDate
        self.fromTime = fromTime
        self.toTime = toTime
        self.priority = priority
        self.daysOfWeek = daysOfWeek
        self.routes = routes
        self.signs = signs
        self.channelMessages = channelMessages

    }
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
    var data: RouteSectionsObject
}

class RouteSectionsObject: Codable {
    var fromStop: [Route]
    var boardingSoon: [Route]
    var walking: [Route]
}

struct MultiRoutesRequest: Codable {
    var success: Bool
    var data: [Route?]
}

class AllBusStopsRequest: Codable {
    var success: Bool
    var data: [Place]

    private enum CodingKeys: CodingKey {
        case success
        case data
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        data = try container.decode([Place].self, forKey: .data)
        parseAllStops()
    }

    // TO BE MOVED TO BACKEND
    func parseAllStops() {

        // Create dictionary of all pulled stops
        let crossReference = data.reduce(into: [String: [Place]]()) {
            $0[$1.name, default: []].append($1)
        }

        // Create an array of all stops that are non duplicates by name
        var nonDuplicateStops = crossReference.filter {$1.count == 1}.map { (_, value) -> Place in
            return value.first!
        }

        // Create an array of all stops that are duplicates by name
        let duplicates = crossReference.filter { $1.count > 1 }

        // Begin filtering stops with same names
        for key in duplicates.keys {
            if
                let currentBusStops = duplicates[key],
                let first = currentBusStops.first,
                let second = currentBusStops.last
            {
                guard
                    let firstLat = first.latitude, let firstLong = first.longitude,
                    let secondLat = second.latitude, let secondLong = second.longitude
                    else {
                    continue
                }
                let firstStopLocation = CLLocation(latitude: firstLat, longitude: firstLong)
                let secondStopLocation = CLLocation(latitude: secondLat, longitude: secondLong)

                let distanceBetween = firstStopLocation.distance(from: secondStopLocation)

                if distanceBetween < Constants.Values.maxDistanceBetweenStops {
                    // If stops are too close to each other, combine into a new stop with averaged location and add to list
                    let middleCoordinate = firstStopLocation.coordinate.middleLocationWith(location: secondStopLocation.coordinate)
                    let middleBusStop = Place(name: first.name, latitude: middleCoordinate.latitude, longitude: middleCoordinate.longitude)
                    middleBusStop.type = .busStop
                    nonDuplicateStops.append(middleBusStop)
                } else {
                    // If not, add directly to the final list to be returned as data
                    nonDuplicateStops.append(contentsOf: [first, second])
                }
            }
        }

        // Sort in alphabetical order
        let sortedStops = nonDuplicateStops.sorted(by: {$0.name.uppercased() < $1.name.uppercased()})
        data = sortedStops
    }
}
