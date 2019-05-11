//
//  BusLocation.swift
//  TCAT
//
//  Created by Matthew Barker on 9/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import MapKit
import UIKit

enum BusDataType: String, Codable {
    /// Invalid data (e.g. bus trip too far in future)
    case invalidData
    /// No data to show
    case noData
    /// Valid data to show
    case validData
}

class BusLocation: NSObject, Codable {

    var dataType: BusDataType
    var delay: Int
    var destination: String
    var deviation: Int
    var direction: String
    var displayStatus: String
    var gpsStatus: Int
    var heading: Int
    var lastStop: String
    var lastUpdated: Date
    var latitude: Double
    var longitude: Double
    var name: String?
    var opStatus: String
    var routeID: Int?
    var runID: Int
    var speed: Int
    var tripID: Int?
    var vehicleID: Int

    private var _iconView: UIView?

    private enum CodingKeys: String, CodingKey {
        case dataType = "case"
        case delay
        case destination
        case deviation
        case direction
        case displayStatus
        case gpsStatus
        case heading
        case lastStop
        case lastUpdated
        case latitude
        case longitude
        case name
        case opStatus
        case routeID
        case runID
        case speed
        case tripID
        case vehicleID
    }

    init(dataType: BusDataType,
         destination: String,
         deviation: Int,
         delay: Int,
         direction: String,
         displayStatus: String,
         gpsStatus: Int,
         heading: Int,
         lastStop: String,
         lastUpdated: Date,
         latitude: Double,
         longitude: Double,
         name: String,
         opStatus: String,
         routeID: Int,
         runID: Int,
         speed: Int,
         tripID: Int,
         vehicleID: Int
    ) {
        self.dataType = dataType
        self.delay = delay
        self.destination = destination
        self.deviation = deviation
        self.direction = direction
        self.displayStatus = displayStatus
        self.gpsStatus = gpsStatus
        self.heading = heading
        self.lastStop = lastStop
        self.lastUpdated = lastUpdated
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.opStatus = opStatus
        self.routeID = routeID
        self.runID = runID
        self.speed = speed
        self.tripID = tripID
        self.vehicleID = vehicleID
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.routeID, forKey: "routeID")
    }

    var iconView: UIView {

        if let iconView = _iconView {
            return iconView
        } else {
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            _iconView = BusLocationView(number: routeNumber, bearing: heading, position: coordinates)
            return _iconView!
        }

    }

    /// The Int type of routeID. Defaults to 0 if can't cast to Int
    var routeNumber: Int {
        return routeID ?? 0
    }

}
