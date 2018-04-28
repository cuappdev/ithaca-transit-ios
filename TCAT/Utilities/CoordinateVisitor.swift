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

enum CoordinateVisitorError: Swift.Error {
    case GooglePlacesLookup(error: Swift.Error, description: String)
    case PlaceResultNil(description: String)
}

class CoordinateVisitor: NSObject {
    
    private let placesClient = GMSPlacesClient.shared()
    
    func getCoordinate(from place: PlaceResult, callback: @escaping (_ coord: CLLocationCoordinate2D?, _ error: CoordinateVisitorError?) -> Void) {
        
        placesClient.lookUpPlaceID(place.placeID) { (result, error) in
            
            if let error = error {
                callback(nil, CoordinateVisitorError.GooglePlacesLookup(error: error, description: "PlaceVisitor visit(place:) lookup place id query error: \(error.localizedDescription)"))
                return
            }
            
            guard let result = result else {
                callback(nil, CoordinateVisitorError.PlaceResultNil(description: "Network visit(place:) no place details for \(place.name) with id \(place.placeID)"))
                return
            }
            
            callback(result.coordinate, nil)
        }
        
    }
    
    func getCoordinate(from busStop: BusStop, callback: @escaping (_ coord: CLLocationCoordinate2D?, _ error: CoordinateVisitorError?) -> Void) {
        
        callback(CLLocationCoordinate2D(latitude: busStop.lat, longitude: busStop.long), nil)
        
    }
}
