//
//  RouteSummaryObject.swift
//  TCAT
//
//  Created by Monica Ong on 9/10/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON
import CoreLocation

enum PinType: String {
    case stop, place
}

enum NextDirection: String {
    case bus, walk
}

class RouteSummaryObject: NSObject, JSONDecodable {

    var name: String
    var type: PinType
    var busNumber: Int?
    var nextDirection: NextDirection?
    
    var location: CLLocationCoordinate2D
    var time: Date
    
    required init(json: JSON) throws {
        name = json["start"]["name"].stringValue
        type = .stop
        
        if(json["busPath"] != JSON.null){
            nextDirection = .bus
            busNumber = json["busPath"]["lineNumber"].intValue
        }else{
            nextDirection = .walk
        }
        
        let long = json["start"]["location"]["longitude"].doubleValue
        let lat = json["start"]["location"]["latitude"].doubleValue
        location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        time = Date(timeIntervalSince1970: json["startTime"].doubleValue)
    }
    
    init(name: String, type: PinType, location: CLLocationCoordinate2D, time: Date) {
        self.name = name
        self.type = type
        self.location = location
        self.time = time
    }
    
    convenience init(name: String, type: PinType, location: CLLocationCoordinate2D, time: Date, nextDirection: NextDirection) {
        self.init(name: name, type: type, location: location, time: time)
        self.nextDirection = nextDirection
    }
    
    convenience init(name: String, type: PinType, location: CLLocationCoordinate2D, time: Date, nextDirection: NextDirection, busNumber: Int) {
        self.init(name: name, type: type, location: location, time: time, nextDirection: nextDirection)
        self.busNumber = busNumber
    }
    
    func updateName(from place: Place) {
        name = place.name
    }
}
