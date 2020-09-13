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
    var latitude: Double
    var longitude: Double
    var routeID: Int
    var vehicleID: Int

    private var _iconView: UIView?

    private enum CodingKeys: String, CodingKey {
        case dataType = "case"
        case latitude
        case longitude
        case routeID
        case vehicleID
    }

    init(
        dataType: BusDataType,
        latitude: Double,
        longitude: Double,
        routeID: Int,
        vehicleID: Int
    ) {
        self.dataType = dataType
        self.latitude = latitude
        self.longitude = longitude
        self.routeID = routeID
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
            _iconView = BusLocationView(number: routeNumber, position: coordinates)
            return _iconView!
        }
    }

    /// The Int type of routeID. Defaults to 0 if can't cast to Int
    var routeNumber: Int {
        return routeID ?? 0
    }

}
