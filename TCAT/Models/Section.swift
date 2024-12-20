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
    case recentSearches(items: [Place])
    case searchResults(items: [Place])
    case seeAllStops

    private func getVal() -> Any? {
        switch self {
        case .seeAllStops:
            return nil

        case .currentLocation(let location):
            return location

        case .recentSearches(let items),
             .searchResults(let items):
            return items
        }
    }

    var isEmpty: Bool {
        switch self {
        case .currentLocation, .seeAllStops:
            return false

        case .recentSearches(let items), .searchResults(let items):
            return items.isEmpty
        }
    }

    func getItems() -> [Place] {
        switch self {
        case .seeAllStops:
            return []

        case .currentLocation(let currLocation):
            return [currLocation]

        case .recentSearches(let items), .searchResults(let items):
            return items
        }
    }

    func getItem(at index: Int) -> Place? {
        switch self {
        case .currentLocation, .seeAllStops:
            return nil

        case .recentSearches(let items), .searchResults(let items):
            return items[optional: index]
        }
    }

    func getCurrentLocation() -> Place? {
        if let loc = self.getVal() as? Place {
            return loc
        }
        return nil
    }
}

extension Section: Equatable {

    public static func == (lhs: Section, rhs: Section) -> Bool {
        switch (lhs, rhs) {
        case (.seeAllStops, .seeAllStops):
            return true

        case (.currentLocation(let locA), .currentLocation(let locB)):
            return locA == locB

        case (.searchResults(let itemsA), .searchResults(let itemsB)),
             (.recentSearches(let itemsA), .recentSearches(let itemsB)):
            return itemsA == itemsB

        default: return false
        }
    }

}
