//
//  Constants.swift
//  TCAT
//
//  Created by Daniel Li on 3/26/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import Foundation

enum Keys: String {

    case fabricAPIKey = "fabric-api-key"
    case fabricBuildSecret = "fabric-build-secret"

    case googleMapsDebug = "google-maps-debug"
    case googleMapsRelease = "google-maps-release"
    case googlePlacesDebug = "google-places-debug"
    case googlePlacesRelease = "google-places-release"

    case registerSecret = "register-secret"

    /// The string value of the key
    var value: String {
        return Keys.keyDict[rawValue] as? String ?? ""
    }

    private static let keyDict: NSDictionary = {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) else { return [:] }
        return dict
    }()

}
