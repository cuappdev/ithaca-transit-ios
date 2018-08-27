//
//  BusStop.swift
//  TCAT
//
//  Created by Austin Astorga on 3/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation

class BusStop: Place, CoordinateAcceptor {

    var lat: CLLocationDegrees
    var long: CLLocationDegrees

    private let latKey = "latitude"
    private let longKey = "longitude"

    init(name: String, lat: CLLocationDegrees, long: CLLocationDegrees) {
        self.lat = lat
        self.long = long
        super.init(name: name)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if (!super.isEqual(object)) {
            return false
        }

        guard let object = object as? BusStop else {
            return false
        }

        return object.lat == lat && object.long == long
    }

    // MARK: Print

    override var description: String {
        return "BusStop(name: \(name), lat: \(lat), long: \(long))"
    }

    // MARK: NSCoding

    required init(coder aDecoder: NSCoder) {
        lat = aDecoder.decodeDouble(forKey: latKey)
        long = aDecoder.decodeDouble(forKey: longKey)

        super.init(coder: aDecoder)
    }

    public override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.lat, forKey: latKey)
        aCoder.encode(self.long, forKey: longKey)

        super.encode(with: aCoder)
    }

    // MARK: Visitor pattern

    func accept(visitor: CoordinateVisitor, callback: @escaping (_ coord: CLLocationCoordinate2D?, _ error: CoordinateVisitorError?) -> Void) {
        visitor.getCoordinate(from: self, callback: callback)
    }
}
