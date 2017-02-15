//
//  SearchLocation.swift
//  TCAT
//
//  Created by Austin Astorga on 2/15/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation

class SearchLocation: NSObject, NSCoding {
    var name: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    init(name: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: NSCoding
    
     required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let latitude = aDecoder.decodeObject(forKey: "latitude") as! CLLocationDegrees
        let longitude = aDecoder.decodeObject(forKey: "longitude") as! CLLocationDegrees
        self.init(name: name, latitude: latitude, longitude: longitude)
        
    }
    
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")

    }
    
}


















