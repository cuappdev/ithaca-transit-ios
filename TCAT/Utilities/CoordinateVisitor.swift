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
    func accept(visitor: CoordinateVisitor, callback: @escaping (_ coord: CLLocationCoordinate2D?, _ error: Swift.Error?) -> Void)
}

enum CoordinateVisitorError: Swift.Error {
    case GooglePlacesLookup(funcName: String, error: Swift.Error)
    case PlaceResultNil(funcName: String, placeResult: PlaceResult)
}

class CoordinateVisitor: NSObject {
    
    private let placesClient = GMSPlacesClient.shared()
    
    func getCoordinate(from place: PlaceResult, callback: @escaping (_ coord: CLLocationCoordinate2D?, _ error: Swift.Error?) -> Void) {
        
        placesClient.lookUpPlaceID(place.placeID) { (result, error) in
            
            if let error = error {
                callback(nil, CoordinateVisitorError.GooglePlacesLookup(funcName: "visit(place:)", error: error))
                return
            }
            
            guard let result = result else {
                callback(nil, CoordinateVisitorError.PlaceResultNil(funcName: "visit(place:)", placeResult: place))
                return
            }
            
            callback(result.coordinate, nil)
        }
        
    }
    
    func getCoordinate(from busStop: BusStop, callback: @escaping (_ coord: CLLocationCoordinate2D?, _ error: Swift.Error?) -> Void) {
        
        callback(CLLocationCoordinate2D(latitude: busStop.lat, longitude: busStop.long), nil)
        
    }
}
