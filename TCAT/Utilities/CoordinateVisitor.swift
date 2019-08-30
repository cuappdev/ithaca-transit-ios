//
//  PlaceVisitor.swift
//  TCAT
//
//  Created by Monica Ong on 10/15/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import FutureNova
import UIKit

struct CoordinateVisitorError: Swift.Error {
    let title: String
    let description: String
}

class CoordinateVisitor: NSObject {

    static private let networking: Networking = URLSession.shared.request

    static func getCoordinates(for place: Place, callback: @escaping (_ latitude: Double?, _ longitude: Double?, _ error: CoordinateVisitorError?) -> Void) {

        let identifier = place.placeIdentifier ?? ""

        getPlaceIDCoordinates(placeID: identifier).observe { result in
            DispatchQueue.main.async {
                switch result {
                case .value(let response):
                    if response.success {
                        callback(response.data.lat, response.data.long, nil)
                    } else {
                        let coordVisitError = CoordinateVisitorError(
                            title: "Place ID Coordinates Lookup",
                            description: "Place ID Coordinates lookup failure"
                        )
                        callback(nil, nil, coordVisitError)
                    }
                case .error(let error):
                    let coordVisitError = CoordinateVisitorError(
                        title: "Place ID Coordinates Lookup",
                        description: "Place ID Coordinates lookup error: \(error.localizedDescription)"
                    )
                    callback(nil, nil, coordVisitError)
                }
            }
        }
    }

    private static func getPlaceIDCoordinates(placeID: String) -> Future<Response<PlaceCoordinates>> {
        return networking(Endpoint.getPlaceIDCoordinates(placeID: placeID)).decode()
    }

}
