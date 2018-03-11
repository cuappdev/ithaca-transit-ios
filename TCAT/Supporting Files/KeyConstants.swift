//
//  UserDefaultKey.swift
//  TCAT
//
//  Created by Monica Ong on 9/16/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation

struct Key {

    struct UserDefaults {
        static let recentSearch = "recentSearch"
        static let allBusStops = "allBusStops"
        static let favorites = "favorites"
    }

    struct FuzzySearch {
        static let minimumValue = 75
    }

    struct Distance {
        static let maxBetweenStops = 160.0
    }

    struct Cells {
        static let busIdentifier = "BusStop"
        static let searchResultsIdentifier = "SearchResults"
        static let cornellDestinationsIdentifier = "CornellDestinations"
        static let seeAllStopsIdentifier = "SeeAllStops"
        static let currentLocationIdentifier = "CurrentLocation"
    }

    struct Favorites {
        static let first = "Add Your First Favorite!"
    }
    
    struct Stops {
        static let currentLocation = "Current Location"
        static let destination = "your destination"
    }
    
}
