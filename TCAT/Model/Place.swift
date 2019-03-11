//
//  Place.swift
//  TCAT
//
//  Created by Monica Ong on 8/31/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

enum PlaceType: String, Codable {
    case busStop, googlePlace, unknown
}

class Place: NSObject, Codable {

    var name: String
    var type: PlaceType
    
    // Additional description of the place (e.g. address, "Bus Stop")
    private var placeDescription: String?
    
    // Metadata related to the place (e.g. Google Place ID)
    var placeIdentifier: String?
    
    var latitude: Double?
    var longitude: Double?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case type
        case placeDescription = "detail"
        case placeIdentifier = "placeID"
        case latitude = "lat"
        case longitude = "long"
    }
    
    init(name: String) {
        self.name = name
        self.type = .unknown
    }
    
    /// Initializer for Google Places
    convenience init(name: String, placeDescription: String, placeIdentifier: String) {
        self.init(name: name)
        self.type = .googlePlace
        self.placeDescription = placeDescription
        self.placeIdentifier = placeIdentifier
    }
    
    /// Initializer for Bus Stops
    convenience init(name: String, latitude: Double, longitude: Double) {
        self.init(name: name)
        self.type = .busStop
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: Functions
    
    override var description: String {
        let exception = name == Constants.General.firstFavorite
        return (type == .googlePlace || exception) ? (placeDescription ?? "") : ("Bus Stop")
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Place else {
            return false
        }
        if let identifier = object.placeIdentifier {
            return identifier == placeIdentifier
        }
        return object.name == name
    }
    
}
