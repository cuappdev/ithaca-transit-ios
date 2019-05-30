//
//  Section.swift
//  TCAT
//
//  Created by Omar Rasheed on 5/29/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation

enum Section {
    case currentLocation(location: CLLocationCoordinate2D?)
    case favorites(items: [Place])
    case recentSearches(items: [Place])
    case searchResults(items: [Place])
    case seeAllStops
    
    func getItems() -> [Place] {
        switch self {
        case .currentLocation, .seeAllStops: return []
        case .favorites(let items),
             .recentSearches(let items),
             .searchResults(let items): return items
        }
    }
    
    func getItem(at index: Int) -> Place? {
        switch self {
        case .currentLocation, .seeAllStops: return nil
        case .favorites(let items),
             .recentSearches(let items),
             .searchResults(let items): return items[optional: index]
        }
    }
    
    func getCurrentLocation() -> Place? {
        switch self {
        case .currentLocation(let loc):
            if let loc = loc {
                return Place(name: Constants.General.currentLocation,
                                              latitude: loc.latitude,
                                              longitude: loc.longitude)
            } else { return nil }
        default: return nil
        }
    }
}
