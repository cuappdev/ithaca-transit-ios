//
//  Route.swift
//  TCAT
//
//  Description:
//      Data model to represent both route options screen (Monica) and route detail screen (Matt)
//
//  Note:
//      - routeSummary is for route options screen (Monica) and directions is for route detail screen (Matt)
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

struct Bounds: Codable {

    /// The minimum latitude value in all of the path's route.
    var minLat: Double

    /// The minimum longitude value in all of the path's route.
    var minLong: Double

    /// The maximum latitude value in all of the path's route.
    var maxLat: Double

    /// The maximum longitude value in all of the path's route.
    var maxLong: Double

}

struct RouteCalculationError: Swift.Error {
    let description: String
    let title: String
}

class Route: NSObject, Codable {

    /// The time a user begins their journey
    var departureTime: Date

    /// The time a user arrives at their destination.
    var arrivalTime: Date

    /// A unique identifier for the route
    var routeId: String

    /// The distance between the start and finish location, in miles
    var travelDistance: Double = 0.0

    /// A list of Direction objects (used for Route Detail)
    var directions: [Direction]

    /// Raw, untampered with directions (for RouteOptionsViewController)
    var rawDirections: [Direction]

    /// A description of the starting location of the route (e.g. Current Location, Arts Quad)
    /// Default assumption is Current Location.
    var startName: String

    /// A description of the final destination of the route (e.g. Chipotle Mexican Grill, The Shops at Ithaca Mall)
    var endName: String

    /// The number of minutes the route will take. Returns 0 in case of error.
    var totalDuration: Int {
        let duration = Time.dateComponents(from: departureTime, to: arrivalTime)
        let minutes = duration.minute ?? 0
        let hours = duration.hour ?? 0
        return minutes + hours * 60
    }

    private enum CodingKeys: String, CodingKey {
        case arrivalTime
        case departureTime
        case directions
        case routeId
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        departureTime = Date.parseDate(try container.decode(String.self, forKey: .departureTime))
        arrivalTime = Date.parseDate(try container.decode(String.self, forKey: .arrivalTime))
        routeId = try container.decode(String.self, forKey: .routeId)
        directions = try container.decode([Direction].self, forKey: .directions)
        rawDirections = try container.decode([Direction].self, forKey: .directions)
        startName = Constants.General.currentLocation
        endName = Constants.General.destination
    }

    func formatDirections(start: String?, end: String?) {
        startName = start ?? Constants.General.currentLocation
        endName = end ?? Constants.General.destination

        let first = 0
        for (index, direction) in rawDirections.enumerated() where direction.type == .walk {
            // Change walking direction name to name of location walking from
            if index == first {
                direction.name = startName
            } else {
                direction.name = rawDirections[index - 1].stops.last?.name ?? rawDirections[index - 1].name
            }
        }

        // Append extra direction for ending location with ending destination name
        if let direction = rawDirections.last {
            // Set stayOnBusForTransfer to false b/c ending location can never have transfer
            if direction.type == .walk || direction.type == .depart,
                let newDirection = direction.copy() as? Direction {
                newDirection.type = newDirection.type == .depart ? .arrive : .walk
                newDirection.stayOnBusForTransfer = false
                newDirection.name = endName
                rawDirections.append(newDirection)
            }
        }

        // Change all walking directions, except for first and last direction, to arrive
        let last = rawDirections.count - 1
        rawDirections.enumerated().forEach { (index, direction) in
            if index != last && index != first && direction.type == .walk {
                direction.type = .arrive
                direction.name = rawDirections[index - 1].stops.last?.name ?? "Bus Stop"
            }
        }

        calculateTravelDistance(fromRawDirections: rawDirections)
        parseAndFormatDirections()
    }

    private func parseAndFormatDirections() {
        // Variable to keep track of additions to direction list (Arrival Directions)
        var offset = 0

        directions.enumerated().forEach { (index, direction) in
            if direction.type == .depart {
                let beyondRange = index + 1 > directions.count - 1
                let isLastDepart = index == directions.count - 1

                if direction.stayOnBusForTransfer {
                    direction.type = .transfer
                }

                // If this direction doesn't have a transfer afterwards, or is depart and last
                if (!beyondRange && !directions[index+1].stayOnBusForTransfer) || isLastDepart,
                    let arriveDirection = direction.copy() as? Direction {
                    // Create Arrival Direction
                    arriveDirection.type = .arrive
                    arriveDirection.startTime = arriveDirection.endTime
                    arriveDirection.startLocation = arriveDirection.endLocation
                    arriveDirection.stops = []
                    arriveDirection.name = direction.stops.last?.name ?? "Bus Stop"
                    directions.insert(arriveDirection, at: index + offset + 1)
                    offset += 1
                }

                // Remove inital bus stop and departure bus stop
                if direction.stops.count >= 2 {
                    direction.stops.removeFirst()
                    direction.stops.removeLast()
                }
            }

            // Change name of last direction to be endName
            if direction == directions.last {
                direction.name = endName
            }
        }
    }

    // MARK: - Process routes

    func isRawWalkingRoute() -> Bool {
        return rawDirections.allSatisfy { $0.type == .walk }
    }

    func getFirstDepartRawDirection() -> Direction? {
        return rawDirections.first { $0.type == .depart }
    }

    // swiftlint:disable:next line_length
    /// Calculate travel distance from location passed in to first route summary object and updates travel distance of route
    func calculateTravelDistance(fromRawDirections rawDirections: [Direction]) {

        // firstRouteOptionsStop = first bus stop in the route
        guard var stop = rawDirections.first else {
            return
        }

        let fromLocation = CLLocation(latitude: stop.startLocation.latitude, longitude: stop.startLocation.longitude)

        // If more than just a walking route that starts with walking
        if !isRawWalkingRoute() && rawDirections.first?.type == .walk && rawDirections.count > 1 {
            stop = rawDirections[1]
        }

        var endLocation = CLLocation(latitude: stop.startLocation.latitude, longitude: stop.startLocation.longitude)

        if isRawWalkingRoute() {
            endLocation = CLLocation(latitude: stop.endLocation.latitude, longitude: stop.endLocation.longitude)
        }

        travelDistance = fromLocation.distance(from: endLocation)

    }

    /// Used for sharing. Return a one sentence summary of the route, based on
    /// the first depart or walking direction. Returns "" if no directions.
    var summaryDescription: String {
        var description = "To get from \(startName) to \(endName),"
        var noDepartDirection = true

        if description.contains(Constants.General.currentLocation) {
            description = "To get to \(endName),"
        }

        let busDirections = directions.filter { $0.type == .depart || $0.type == .transfer }

        for (index, direction) in busDirections.enumerated() {
            noDepartDirection = false

            let number = direction.routeNumber
            let start = direction.stops.first?.name ?? "starting location"
            let end = direction.stops.last?.name ?? "ending location"
            var line = "take Route \(number) from \(start) to \(end). "

            if direction.type == .transfer {
                line = "the bus becomes Route \(number). Stay on board, and then get off at \(end)"
            }

            if index == 0 {
                description += " \(line)"
            } else {
                description += "Then, \(line)"
            }
        }

        description += "."

        // Walking Direction
        if noDepartDirection {
            guard let direction = directions.first else {
                return ""
            }
            let distance = direction.travelDistance.roundedString
            description = "Walk \(distance) from \(startName) to \(endName)."
        }

        return description
    }

}
