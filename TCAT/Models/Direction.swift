//
//  Direction.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import SwiftyJSON
import UIKit

/// An enum for the type of direction
enum DirectionType: String, Codable {

    /// Direction where the user gets off the bus
    case arrive
    /// Directions where the user gets on the bus
    case depart
    /// Direction where transfer is involved, but user stays on bus
    case transfer
    /// Directions that involving walking
    case walk

}

class Direction: NSObject, NSCopying, Codable {

    /// The type of the direction.
    var type: DirectionType

    ///
    /// General description for the direction.
    /// 
    /// - walk: The description of the place / location the user is walking to
    /// - depart: The name of the bus stop where the bus is departing from
    /// - arrive: The name of the bus stop where the user gets off the bus
    /// 
    var name: String

    /// The starting location object associated with the direction
    /// If this is a bus stop, includes stopID as id.
    var startLocation: CLLocationCoordinate2D

    /// The ending location object associated with the direction
    /// If this is a bus stop, includes stopID as id.
    var endLocation: CLLocationCoordinate2D

    /// The starting time (UTC) associated with the direction. Format: `"yyyy-MM-dd'T'HH:mm:ssZZZZ"`
    var startTime: Date

    /// The ending time (UTC) associated with the direction Format: `"yyyy-MM-dd'T'HH:mm:ssZZZZ"`
    var endTime: Date

    /// The corresponding path of the direction
    var path: [CLLocationCoordinate2D]

    /// The total distance of the direction, in meters.
    var travelDistance: Double = 0

    /// The number representing the bus route.
    var routeNumber: Int = 0

    // swiftlint:disable:next line_length
    /// An array of bus stop locations on the bus route, including the departure and arrival stop. Empty if `type != .depart`.
    var stops: [LocationObject] = []

    /// Whether the user should stay on this direction's bus for an upcoming transfer.
    var stayOnBusForTransfer: Bool = false

    /// The unique identifiers for the specific bus related to the direction.
    var tripIdentifiers: [String]?

    /// The bus delay for stops[0]
    var delay: Int?

    private enum CodingKeys: String, CodingKey {
        case delay
        case endLocation
        case endTime
        case name
        case path
        case routeNumber
        case startLocation
        case startTime
        case stayOnBusForTransfer
        case stops
        case travelDistance = "distance"
        case tripIdentifiers
        case type
    }

    // MARK: - Initalizers

    required init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = try container.decode(DirectionType.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        startLocation = try container.decode(CLLocationCoordinate2D.self, forKey: .startLocation)
        endLocation = try container.decode(CLLocationCoordinate2D.self, forKey: .endLocation)
        startTime = Date.parseDate(try container.decode(String.self, forKey: .startTime))
        endTime = Date.parseDate(try container.decode(String.self, forKey: .endTime))
        path = try container.decode([CLLocationCoordinate2D].self, forKey: .path)

        do {
            routeNumber = try container.decode(Int.self, forKey: .routeNumber)
        } catch {
            routeNumber = -1
        }

        stops = try container.decode([LocationObject].self, forKey: .stops)

        do {
            stayOnBusForTransfer = try container.decode(Bool.self, forKey: .stayOnBusForTransfer)
        } catch { stayOnBusForTransfer = false
        }

        tripIdentifiers = try container.decode([String]?.self, forKey: .tripIdentifiers)

        do {
            delay = try container.decode(Int?.self, forKey: .delay)
        } catch {
            delay = nil
        }

        travelDistance = try container.decode(Double.self, forKey: .travelDistance)

        super.init()
    }

    required init (
        type: DirectionType = .walk,
        name: String = "",
        startLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
        endLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
        startTime: Date = Date(),
        endTime: Date = Date(),
        path: [CLLocationCoordinate2D] = [],
        travelDistance: Double = 0,
        routeNumber: Int = 0,
        stops: [LocationObject] = [],
        stayOnBusForTransfer: Bool = false,
        tripIdentifiers: [String]? = [],
        delay: Int? = 0
    ) {
        self.type = type
        self.name = name
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startTime = startTime
        self.endTime = endTime
        self.path = path
        self.travelDistance = travelDistance
        self.routeNumber = routeNumber
        self.stops = stops
        self.stayOnBusForTransfer = stayOnBusForTransfer
        self.tripIdentifiers = tripIdentifiers
        self.delay = delay
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return Swift.type(of: self).init(
            type: type,
            name: name,
            startLocation: startLocation,
            endLocation: endLocation,
            startTime: startTime,
            endTime: endTime,
            path: path,
            travelDistance: travelDistance,
            routeNumber: routeNumber,
            stops: stops,
            stayOnBusForTransfer: stayOnBusForTransfer,
            tripIdentifiers: tripIdentifiers,
            delay: delay
        )
    }

    // MARK: - Descriptions

    /// Returns custom description for locationName based on DirectionType
    var locationNameDescription: String {
        switch type {
        case .depart:
            return "at \(name)"

        case .arrive:
            return "Get off at \(name)"

        case .walk:
            return "Walk to \(name)"

        case .transfer:
            return "at \(name). Stay on bus."
        }
    }

    override var debugDescription: String {
        return """
        {
            type: \(type),
            name: \(name),
            startTime: \(startTime),
            endTime: \(endTime),
            startLocation: \(stops.first?.name ?? "Unknown"),
            endLocation: \(stops.last?.name ?? "Unknown"),
            distance: \(travelDistance),
            locationNameDescription: \(locationNameDescription),
            numberOfStops: \(stops.count)
            routeNumber: \(routeNumber)
            stayOnBusTransfer: \(stayOnBusForTransfer)
        }
        """
    }

    // MARK: - Complex Variables & Functions

    /// Returns readable start time (e.g. 7:49 PM)
    var startTimeDescription: String {
        return timeDescription(startTime)
    }

    /// Returns readable end time (e.g. 7:49 PM)
    var endTimeDescription: String {
        return timeDescription(endTime)
    }

    /// Return the start time with the delay added.
    var startTimeWithDelay: Date {
        return startTime.addingTimeInterval(TimeInterval(delay ?? 0))
    }

    /// Return the end time with the delay added.
    var endTimeWithDelay: Date {
        return endTime.addingTimeInterval(TimeInterval(delay ?? 0))
    }

    var startTimeWithDelayDescription: String {
        return timeDescription(startTimeWithDelay)
    }

    var endTimeWithDelayDescription: String {
        return timeDescription(endTimeWithDelay)
    }

    private func timeDescription(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

}
