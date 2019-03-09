//
//  TodayExtensionHelpers.swift
//  Today Extension
//
//  Created by Yana Sang on 2/3/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Foundation

class TodayExtensionManager {
    
    static let shared = TodayExtensionManager()
    let decoder = JSONDecoder()

    func retrieveFavoritesNames() -> [String] {
        if
            let storedPlaces = sharedUserDefaults?.value(forKey: Constants.UserDefaults.favorites) as? Data,
            let places = try? decoder.decode([Place].self, from: storedPlaces)
        {
            var favorites: [String] = []
            for place in places {
                favorites.append(place.name)
            }
            return favorites
        }
        print("Failed to retreive favorites from User Defaults")
        return [String]()
    }
    
    func retrieveFavoritesCoordinates() -> [String] {
        if
            let storedPlaces = sharedUserDefaults?.value(forKey: Constants.UserDefaults.favorites) as? Data,
            let places = try? decoder.decode([Place].self, from: storedPlaces)
        {
            var coordinates: [String] = []
            for place in places {
                if
                    let lat = place.latitude,
                    let long = place.longitude {
                    coordinates.append("\(lat),\(long)")
                }
            }
            return coordinates
        }
        print("Failed to retreive favorites' coordinates from User Defaults")
        return [String]()
    }
}
