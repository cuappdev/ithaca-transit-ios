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
    var routeId: String
    var vehicleId: String

    private var _iconView: UIView?

    private enum CodingKeys: String, CodingKey {
        case dataType = "case"
        case latitude
        case longitude
        case routeId
        case vehicleId
    }

    init(
        dataType: BusDataType,
        latitude: Double,
        longitude: Double,
        routeId: String,
        vehicleId: String
    ) {
        self.dataType = dataType
        self.latitude = latitude
        self.longitude = longitude
        self.routeId = routeId
        self.vehicleId = vehicleId
    }

    // Temporary fix -- backend returns vehicleId as a string if live tracking is available for the bus, but an integer 0 if not.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Firsts attempts to decode as a String, but decodes as Int if it fails.
        if let vehicleIdString = try? container.decode(String.self, forKey: .vehicleId) {
            self.vehicleId = vehicleIdString
        } else if let vehicleIdInt = try? container.decode(Int.self, forKey: .vehicleId) {
            self.vehicleId = String(vehicleIdInt)
        } else {
            self.vehicleId = "0"
        }

        self.dataType = try container.decode(BusDataType.self, forKey: .dataType)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.routeId = try container.decode(String.self, forKey: .routeId)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.routeId, forKey: "routeId")
    }

    var iconView: UIView {
        if let iconView = _iconView {
            return iconView
        } else {
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            _iconView = BusLocationView(number: Int(routeId) ?? 0, position: coordinates)
            return _iconView!
        }
    }

    /// The Int type of routeID. Defaults to 0 if can't cast to Int
    var routeNumber: String {
        return routeId
    }

}
