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
    case applePlace, busStop, unknown
}

@objc(Place) class Place: NSObject, Codable {

    var name: String
    var type: PlaceType

    /// Additional description of the place (e.g. address, "Bus Stop")
    private var placeDescription: String?

    var latitude: Double?
    var longitude: Double?

    private enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "long"
        case name
        case placeDescription = "detail"
        case type
    }

    /// Initializer for any type of location.
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.type = .unknown
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Initializer for Apple Places
    convenience init(name: String, latitude: Double, longitude: Double, placeDescription: String) {
        self.init(name: name, latitude: latitude, longitude: longitude)
        self.type = .applePlace
        self.placeDescription = placeDescription
    }

    // MARK: - Functions

    override var description: String {
        let exception = name == Constants.General.firstFavorite
        return (type == .applePlace || exception) ? (placeDescription ?? "") : ("Bus Stop")
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Place else {
            return false
        }
        return object.name == name
    }

}
