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

    let userDefaults = UserDefaults(suiteName: "group.tcat")

    func retrieveFavoritesNames(for key: String) -> [String] {
        if let storedFavorites = userDefaults?.value(forKey: key) as? Data {
            NSKeyedUnarchiver.setClass(PlaceResult.self, forClassName: "TCAT.PlaceResult")
            NSKeyedUnarchiver.setClass(BusStop.self, forClassName: "TCAT.BusStop")
            if let places = NSKeyedUnarchiver.unarchiveObject(with: storedFavorites) as? [Any] {
                var favorites: [String] = []
                for place in places {
                    if let place = place as? Place {
                        favorites.append(place.name)
                    }
                }
                return favorites
            }
        }
        print("Failed to retreive favorites from User Defaults")
        return [String]()
    }

}
