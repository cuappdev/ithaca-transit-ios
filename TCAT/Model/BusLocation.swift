//
//  BusLocation.swift
//  TCAT
//
//  Created by Matthew Barker on 9/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import MapKit

enum BusDataType: String {
    /// No data to show
    case noData
    /// Valid data to show
    case validData
    /// Invalid data (e.g. bus trip too far in future)
    case invalidData
}

class BusLocation: NSObject, NSCoding {
    
    var dataType: BusDataType = .noData
    var destination: String = ""
    var deviation: Int = 0
    var delay: Int = 0
    var direction: String = ""
    var displayStatus: String = ""
    var gpsStatus: Int = 0
    var heading: Int = 0
    var lastStop: String = ""
    var lastUpdated: Date = .distantPast
    var latitude: Double = 0
    var longitude: Double = 0
    var name: Int = 0
    var opStatus: String = ""
    var routeID: String = ""
    var runID: Int = 0
    var speed: Int = 0
    var tripID: String = ""
    var vehicleID: Int = 0
    
    fileprivate var _iconView: UIView? = nil
    
    init(routeID: String) {
        self.routeID = routeID
    }
    
    // MARK: NSCoding
    
    required convenience init(coder aDecoder: NSCoder) {
        let routeID = aDecoder.decodeObject(forKey: "routeID") as! String
        self.init(routeID: routeID)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.routeID, forKey: "routeID")
    }
    
    var iconView: UIView {
        
        if let iconView = _iconView {
            return iconView
        } else {
            _iconView = BusLocationView(number: Int(routeID) ?? 0, bearing: heading)
            return _iconView!
        }
        
    }
    
}
