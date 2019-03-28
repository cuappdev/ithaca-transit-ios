//
//  TodayExtensionHelpers.swift
//  Today Extension
//
//  Created by Yana Sang on 2/3/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Foundation

class TodayExtensionManager {

    let decoder = JSONDecoder()
    static let shared = TodayExtensionManager()

    func retrieveFavoritesNames() -> [String] {
        if let storedPlaces = sharedUserDefaults?.value(forKey: Constants.UserDefaults.favorites) as? Data,
            let places = try? decoder.decode([Place].self, from: storedPlaces)
        {
            return places.map({ $0.name })

        } else {
            return []
        }
    }

    func retrieveFavoritesCoordinates() -> [String] {
        if let storedPlaces = sharedUserDefaults?.value(forKey: Constants.UserDefaults.favorites) as? Data,
            let places = try? decoder.decode([Place].self, from: storedPlaces)
        {
            return places.compactMap({
                if let lat = $0.latitude, let long = $0.longitude {
                    return "\(lat),\(long)"
                }
                return nil
            })
        } else {
            return []
        }
    }
}
