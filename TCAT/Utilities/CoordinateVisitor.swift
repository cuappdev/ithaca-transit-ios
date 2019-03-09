//
//  PlaceVisitor.swift
//  TCAT
//
//  Created by Monica Ong on 10/15/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import GooglePlaces

struct CoordinateVisitorError: Swift.Error {
    let title: String
    let description: String
}

class CoordinateVisitor: NSObject {
    
    static private let placesClient = GMSPlacesClient.shared()
    
    static func getCoordinates(for place: Place, callback: @escaping (_ latitude: Double?, _ longitude: Double?, _ error: CoordinateVisitorError?) -> Void) {
        
        let identifier = place.placeIdentifier ?? ""
        
        placesClient.lookUpPlaceID(identifier) { (result, error) in
            
            if let error = error {
                let coordVisitError = CoordinateVisitorError(
                    title: "Google Places Lookup",
                    description: "PlaceVisitor visit(place:) lookup place id query error: \(error.localizedDescription)"
                )
                callback(nil, nil, coordVisitError)
                return
            }
            
            guard let result = result else {
                let coordVisitError = CoordinateVisitorError(
                    title: "PlaceResult is nil",
                    description: "Network visit(place:) result is nil for \(place.name) with id \(identifier)"
                )
                callback(nil, nil, coordVisitError)
                return
            }
            
            callback(result.coordinate.latitude, result.coordinate.longitude, nil)
        }
        
    }
    
}
