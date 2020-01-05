//
//  Place.swift
//  TCAT
//
//  Created by Monica Ong on 8/31/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import UIKit

enum PlaceType: String, Codable {
    case applePlace, busStop, currentLocation
}

struct Place {

    private var placeDescription: String?

    let latitude: Double
    let longitude: Double
    let name: String
    let type: PlaceType

    var description: String {
        return type == .busStop ? "Bus Stop" : placeDescription ?? ""
    }

    init(name: String, type: PlaceType, latitude: Double, longitude: Double, placeDescription: String? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
        self.placeDescription = placeDescription
    }

}

extension Place: Codable {

    private enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "long"
        case name
        case placeDescription = "detail"
        case type
    }

}

extension Place: Equatable {

    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.name == rhs.name && lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

}
