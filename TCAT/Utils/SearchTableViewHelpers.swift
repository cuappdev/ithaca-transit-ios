//
//  SearchTableViewHelpers.swift
//  TCAT
//
//  Created by Austin Astorga on 5/8/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import DZNEmptyDataSet

let encoder = JSONEncoder()
let decoder = JSONDecoder()

class Global {

    static let shared = Global()

    func retrievePlaces(for key: String) -> [Place] {
        if let storedPlaces = userDefaults.value(forKey: key) as? Data,
            let places = try? decoder.decode([Place].self, from: storedPlaces) {
            return places
        }
        return [Place]()
    }

    /// Returns the rest so we don't have to re-unarchive it
    func deleteFavorite(favorite: Place, allFavorites: [Place]) -> [Place] {
        let newFavoritesList = allFavorites.filter { favorite != $0 }
        do {
            let data = try encoder.encode(newFavoritesList)
            userDefaults.set(data, forKey: Constants.UserDefaults.favorites)
            AppShortcuts.shared.updateShortcutItems()
        } catch let error {
            print(error)
        }
        return newFavoritesList
    }

    /// Returns the rest so we don't have to re-unarchive it
    func deleteRecent(recent: Place, allRecents: [Place]) -> [Place] {
        let newRecentsList = allRecents.filter { recent != $0 }
        do {
            let data = try encoder.encode(newRecentsList)
            userDefaults.set(data, forKey: Constants.UserDefaults.recentSearch)
        } catch let error {
            print(error)
        }

        return newRecentsList
    }

    /// Clears recent searches
    func deleteAllRecents() {
        let newRecents = [Place]()
        do {
            let data = try encoder.encode(newRecents)
            userDefaults.set(data, forKey: Constants.UserDefaults.recentSearch)
        } catch let error {
            print(error)
        }
    }

    /// Possible Keys: Constants.UserDefaults (.recentSearch | .favorites)
    func insertPlace(for key: String, place: Place, bottom: Bool = false) {

        // Could replace with an enum
        let limit = key == Constants.UserDefaults.favorites ? 5 : 8

        // Ensure duplicates aren't added
        var places = retrievePlaces(for: key).filter { (savedPlace) -> Bool in
            return savedPlace != place
        }

        places = bottom ? places + [place] : [place] + places

        if places.count > limit { places.remove(at: places.count - 1) }

        do {
            let data = try encoder.encode(places)
            userDefaults.set(data, forKey: key)
            AppShortcuts.shared.updateShortcutItems()
        } catch let error {
            print(error)
        }

        if key == Constants.UserDefaults.favorites {
            let payload = FavoriteAddedPayload(name: place.name)
            TransitAnalytics.shared.log(payload)
        }
    }

}
