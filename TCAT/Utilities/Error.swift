//
//  Error.swift
//  TCAT
//
//  Created by Monica Ong on 4/28/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import Foundation

enum CoordinateVisitorError: Swift.Error {
    case GooglePlacesLookup(funcName: String, error: Swift.Error)
    case PlaceResultNil(funcName: String, placeResult: PlaceResult)
}

enum NetworkError: Swift.Error {
    
}
