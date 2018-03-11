//
//  UserDefaultConstants.swift
//  TCAT
//
//  Created by Monica Ong on 9/16/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation

/// App-wide constants
struct Constants {
    
    struct Cells {
        static let busIdentifier = "BusStop"
        static let searchResultsIdentifier = "SearchResults"
        static let cornellDestinationsIdentifier = "CornellDestinations"
        static let seeAllStopsIdentifier = "SeeAllStops"
        static let currentLocationIdentifier = "CurrentLocation"
        static let smallDetailCellIdentifier = "SmallCell"
        static let largeDetailCellIdentifier = "LargeCell"
        static let busStopCellIdentifier = "BusStopCell"
    }
    
    /// Font identifiers
    struct Fonts {
        
        struct SanFrancisco {
            static let Regular = "SFUIText-Regular"
            static let Medium = "SFUIText-Medium"
            static let Bold = "SFUIText-Bold"
            static let Semibold = "SFUIText-Semibold"
        }
        
    }
    
    struct Phrases {
        static let firstFavorite = "Add Your First Favorite!"
    }
    
    struct UserDefaults {
        static let recentSearch = "recentSearch"
        static let allBusStops = "allBusStops"
        static let favorites = "favorites"
    }
    
    struct Values {
        static let maxDistanceBetweenStops = 160.0
        static let fuzzySearchMinimumValue = 75
    }
    
    struct Stops {
        static let currentLocation = "Current Location"
        static let destination = "your destination"
    }
    
}
