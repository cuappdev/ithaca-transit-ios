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

enum PinType: String {
    case stop, place, currentLocation
}

enum NextDirection: String {
    case bus, walk
}

class RouteSummaryObject: NSObject /* , JSONDecodable */ {

    var name: String
    var type: PinType
    var busNumber: Int?
    var nextDirection: NextDirection?
    
//    required init(json: JSON) throws {
//
//        name = json["name"].stringValue
//        type = PinType(rawValue: json["type"].stringValue)!
//
//        if json["nextDirection"].stringValue != "none" {
//
//            nextDirection = NextDirection(rawValue: json["nextDirection"].stringValue)!
//
//            if nextDirection == .bus {
//                busNumber = json["busNumber"].intValue
//            }
//
//        }
//
//        //
//
//        if json["busPath"] != JSON.null {
//            busNumber = json["busPath"]["lineNumber"].intValue
//        }
//
//        super.init()
//
//    }
    
    init(name: String, type: PinType) {
        self.name = name
        self.type = type
    }
    
    convenience init(name: String, type: PinType, nextDirection: NextDirection) {
        self.init(name: name, type: type)
        self.nextDirection = nextDirection
    }
    
    convenience init(name: String, type: PinType, nextDirection: NextDirection, busNumber: Int) {
        self.init(name: name, type: type, nextDirection: nextDirection)
        self.busNumber = busNumber
    }
    
    func updateNameAndPin(fromPlace place: Place) {
        
        name = place.name
        
        if let busStop = place as? BusStop {
            if busStop.name == "Current Location" {
                type = .currentLocation
            }
            type = .stop
        }
            
        else if place is PlaceResult {
            type = .place
        }
        
    }
}
