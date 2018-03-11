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

class BusLocation: NSObject {
    
    var dataType: BusDataType
    var destination: String
    var deviation: Int
    var delay: Int
    var direction: String
    var displayStatus: String
    var gpsStatus: Int
    var heading: Int
    var lastStop: String
    var lastUpdated: Date
    var latitude: Double
    var longitude: Double
    var name: Int
    var opStatus: String
    var routeID: String
    var runID: Int
    var speed: Int
    var tripID: String
    var vehicleID: Int
    
    fileprivate var _iconView: UIView? = nil
    
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
         name: Int,
         opStatus: String,
         routeID: String,
         runID: Int,
         speed: Int,
         tripID: String,
         vehicleID: Int
    ) {
        self.dataType = dataType
        self.destination = destination
        self.deviation = deviation
        self.delay = delay
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
            _iconView = BusLocationView(number: Int(routeID) ?? 0, bearing: heading)
            return _iconView!
        }
        
    }
    
    /// The Int type of routeID. Defaults to 0 if can't cast to Int
    var routeNumber: Int {
        return Int(routeID) ?? 0
    }
    
}
