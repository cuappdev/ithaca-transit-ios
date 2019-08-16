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
    case currentLocation(location: Place)
    case favorites(items: [Place])
    case recentSearches(items: [Place])
    case searchResults(items: [Place])
    case seeAllStops

    var isEmpty: Bool {
        switch self {
        case .currentLocation, .seeAllStops: return false
        case .favorites(let items),
             .recentSearches(let items),
             .searchResults(let items): return items.isEmpty
        }
    }

    func getItems() -> [Place] {
        switch self {
        case .seeAllStops: return []
        case .currentLocation(let currLocation): return [currLocation]
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
        case .currentLocation(let loc): return loc
        default: return nil
        }
    }
}

extension Section: Equatable {

    public static func == (lhs: Section, rhs: Section) -> Bool {

        switch (lhs, rhs) {
        case (.seeAllStops, .seeAllStops):
            return true
        case (.currentLocation(let locA), .currentLocation(let locB)):
            return locA == locB
        case (.favorites(let itemsA), .favorites(let itemsB)),
             (.searchResults(let itemsA), .searchResults(let itemsB)),
             (.recentSearches(let itemsA), .recentSearches(let itemsB)):
            return itemsA == itemsB
        default: return false
        }
    }
}
