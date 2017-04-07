//
//  BusStop.swift
//  TCAT
//
//  Created by Austin Astorga on 3/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation

class BusStop: NSObject, NSCoding, JSONDecodable {
    var name: String?
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    
    
    init(name: String, lat: CLLocationDegrees, long: CLLocationDegrees) {
        self.name = name
        self.lat = lat
        self.long = long
    }
    
    // MARK: NSCoding
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let latitude = aDecoder.decodeObject(forKey: "latitude") as! CLLocationDegrees
        let longitude = aDecoder.decodeObject(forKey: "longitude") as! CLLocationDegrees
        self.init(name: name, lat: latitude, long: longitude)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.lat, forKey: "latitude")
        aCoder.encode(self.long, forKey: "longitude")
    }
}
