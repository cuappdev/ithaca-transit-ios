//
//  RouteSummaryObject.swift
//  TCAT
//
//  Created by Monica Ong on 9/10/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation

enum PinType: String {
    case stop, place
}

enum NextDirection: String {
    case bus, walk
}

class RouteSummaryObject: NSObject {

    var name: String
    var type: PinType
    var busNumber: Int?
    var nextDirection: NextDirection?
    
    override var description: String {
        return """
        {
            name: \(name),
            type: \(type.rawValue),
            busNumber: \(busNumber ?? -1),
            nextDirection: \(nextDirection?.rawValue ?? "nil")
        }
        """
    }
    
    init(direction: Direction) {
        name = direction.name
        type = direction.type == .walk ? PinType.place : PinType.stop
        busNumber = direction.routeNumber
        nextDirection = direction.type == .depart ? NextDirection.bus: NextDirection.walk
    }
    
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
    
    func updateName(from place: Place) {
        name = place.name
    }
    
    func removeNextDirection() {
        nextDirection = nil
    }
}
