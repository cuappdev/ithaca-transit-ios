//
//  PlaceVisitor.swift
//  TCAT
//
//  Created by Monica Ong on 10/15/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

protocol CoordinateAcceptor {
    func accept(visitor: CoordinateVisitor, callback: @escaping (_ coord: CLLocationCoordinate2D?, _ error: CoordinateVisitorError?) -> Void)
}

struct CoordinateVisitorError: Swift.Error {
    let title: String
    let description: String
}

class CoordinateVisitor: NSObject {

    private let placesClient = GMSPlacesClient.shared()

    func getCoordinate(from place: PlaceResult, callback: @escaping (_ coord: CLLocationCoordinate2D?, _ error: CoordinateVisitorError?) -> Void) {

        placesClient.lookUpPlaceID(place.placeID) { (result, error) in

            if let error = error {
                callback(nil, CoordinateVisitorError(title: "Google Places Lookup", description: "PlaceVisitor visit(place:) lookup place id query error: \(error.localizedDescription)"))
                return
            }

            guard let result = result else {
                callback(nil, CoordinateVisitorError(title: "PlaceResult is nil", description: "Network visit(place:) result is nil for \(place.name) with id \(place.placeID)"))
                return
            }

            callback(result.coordinate, nil)
        }

    }

    func getCoordinate(from busStop: BusStop, callback: @escaping (_ coord: CLLocationCoordinate2D?, _ error: CoordinateVisitorError?) -> Void) {

        callback(CLLocationCoordinate2D(latitude: busStop.lat, longitude: busStop.long), nil)

    }
}
