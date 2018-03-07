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
    func accept(visitor: CoordinateVisitor, callback: @escaping (CLLocationCoordinate2D?) -> Void)
}

class CoordinateVisitor: NSObject {
    
    private let placesClient = GMSPlacesClient.shared()
    
    func getCoordinate(from place: PlaceResult, callback: @escaping (CLLocationCoordinate2D?) -> Void) {
        
        placesClient.lookUpPlaceID(place.placeID) { (result, error) in
            
            if let error = error {
                print("PlaceVisitor visit(place:) lookup place id query error: \(error.localizedDescription)")
                callback(nil)
                return
            }
            
            guard let result = result else {
                print("Network visit(place:) no place details for \(place.name) with id \(place.placeID) ")
                callback(nil)
                return
            }
            
            callback(result.coordinate)
        }
        
    }
    
    func getCoordinate(from busStop: BusStop, callback: @escaping (CLLocationCoordinate2D?) -> Void) {
        
        callback(CLLocationCoordinate2D(latitude: busStop.lat, longitude: busStop.long))
        
    }
}
