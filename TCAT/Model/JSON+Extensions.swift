//
//  Direction.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SwiftyJSON

extension JSON {
    
    /// Format date with pattern `"yyyy-MM-dd'T'HH:mm:ssZZZZ"`. Returns current date on error.
    func parseDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return dateFormatter.date(from: self.stringValue) ?? Date.distantPast
    }
    
    /// Create coordinate object from JSON.
    func parseCoordinates() -> CLLocationCoordinate2D {
        let latitude = self["lat"].doubleValue
        let longitude = self["long"].doubleValue
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Create Bounds object
    func parseBounds() -> Bounds {
        return Bounds(
            minLat: self["minLat"].doubleValue,
            minLong: self["minLong"].doubleValue,
            maxLat: self["maxLat"].doubleValue,
            maxLong: self["maxLong"].doubleValue
        )
    }
    
    // Return LocationObject
    func parseLocationObject() -> LocationObject {
        return LocationObject(
            name: self["name"].stringValue,
            latitude: self["lat"].doubleValue,
            longitude: self["long"].doubleValue
        )
    }
    
}



