//
//  SearchTableViewHelpers.swift
//  TCAT
//
//  Created by Austin Astorga on 5/8/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON
import DZNEmptyDataSet
import Fuzzywuzzy_swift
let userDefaults = UserDefaults.standard

struct Section {
    let type: SectionType
    var items: [ItemType]
}

enum SectionType {
    case cornellDestination
    case recentSearches
    case seeAllStops
    case searchResults
    case currentLocation
    case favorites
}

enum ItemType {
    case busStop(BusStop)
    case placeResult(PlaceResult)
    case cornellDestination
    case seeAllStops
}

/* DZNEmptyDataSet DataSource */

extension SearchResultsTableViewController: DZNEmptyDataSetSource {
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -80.0
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "emptyPin")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let locationNotFound = "Location not found"
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.mediumGrayColor]
        return NSAttributedString(string: locationNotFound, attributes: attrs)
    }
}

class SearchTableViewManager {
    static let shared = SearchTableViewManager()
    private var allStops: [BusStop]?

    private init(){}
    func getAllStops() -> [BusStop] {
        if let stops = allStops {
            return stops
        }
        let stops = getAllBusStops()
        allStops = stops
        return stops
    }

    private func getAllBusStops() -> [BusStop] {
        if let allBusStops = userDefaults.value(forKey: Key.UserDefaults.allBusStops) as? Data,
            let busStopArray = NSKeyedUnarchiver.unarchiveObject(with: allBusStops) as? [BusStop] {
            return busStopArray
        }
        return [BusStop]()
    }

    func parseGoogleJSON(searchText: String, json: JSON) -> Section {
        var itemTypes: [ItemType] = []

        let busStopsWithLevenshtein: [(BusStop, Int)] = getAllStops().map({ ($0, String.fuzzPartialRatio(str1: $0.name.lowercased(), str2: searchText.lowercased())) })
        var filteredBusStops = busStopsWithLevenshtein.filter({$0.1 > Key.FuzzySearch.minimumValue})
        filteredBusStops.sort(by: {$0.1 > $1.1})
        itemTypes = filteredBusStops.map( {ItemType.busStop($0.0)})

        var googleResults: [ItemType] = []
        if let predictionsArray = json["predictions"].array {
            for result in predictionsArray {
                let placeResult = PlaceResult(name: result["structured_formatting"]["main_text"].stringValue, detail: result["structured_formatting"]["secondary_text"].stringValue, placeID: result["place_id"].stringValue)
                let isPlaceABusStop = filteredBusStops.contains(where: {(stop) -> Bool in
                    placeResult.name.contains(stop.0.name)
                })
                if !isPlaceABusStop {
                    googleResults.append(ItemType.placeResult(placeResult))
                }
            }
        }
        return Section(type: .searchResults, items: googleResults + itemTypes)
    }

    func retrieveRecentPlaces(for key: String) -> [ItemType] {
        if let storedPlaces = userDefaults.value(forKey: key) as? Data {
            let places = NSKeyedUnarchiver.unarchiveObject(with: storedPlaces) as! [Any]
            var itemTypes: [ItemType] = []
            for place in places {
                if let busStop = place as? BusStop {
                    itemTypes.append(.busStop(busStop))
                }
                if let searchResult = place as? PlaceResult {
                    itemTypes.append(.placeResult(searchResult))
                }
            }
            return itemTypes
        }
        return [ItemType]()
    }

    //returns the rest so we don't have to re-unarchive it
    func deleteFavorite(favorite: Any, allFavorites: [ItemType]) -> [ItemType] {
        var newFavoritesList: [ItemType] = []
        for item in allFavorites {
            switch item {
            case .busStop(let busStop):
                if let fav = favorite as? BusStop, areObjectsEqual(type: BusStop.self, a: busStop, b: fav) {
                    continue
                } else {
                    newFavoritesList.append(item)
                }
            case .placeResult(let placeResult):
                if let fav = favorite as? PlaceResult, areObjectsEqual(type: PlaceResult.self, a: placeResult, b: fav) {
                    continue
                } else {
                    newFavoritesList.append(item)
                }
            default: break
            }
        }
        let itemsToStore = newFavoritesList.map { (item) -> Any in
            switch item {
            case .busStop(let busStop):
                return busStop
            case .placeResult(let placeResult):
                return placeResult
            default: return ""
            }
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: itemsToStore)
        userDefaults.set(data, forKey: Key.UserDefaults.favorites)
        return newFavoritesList
    }

    func insertPlace(for key: String, location: Any, limit: Int, bottom: Bool = false) {
        let placeItemTypes = retrieveRecentPlaces(for: key)
        let convertedPlaces = placeItemTypes.map( { item -> Any in
            switch item {
            case .busStop(let busStop): return busStop
            case .placeResult(let placeResult): return placeResult
            default: return "this shouldn't ever fire"
            }
        })
        let filteredPlaces = location is BusStop ? convertedPlaces.filter({ !areObjectsEqual(type: BusStop.self, a: location, b: $0)}) : convertedPlaces.filter({ !areObjectsEqual(type: PlaceResult.self, a: location, b: $0)})

        var updatedPlaces: [Any]!
        if bottom {
            updatedPlaces = filteredPlaces + [location]
        } else {
            updatedPlaces = [location] + filteredPlaces
        }
        if updatedPlaces.count > limit { updatedPlaces.remove(at: updatedPlaces.count - 1)}
        let data = NSKeyedArchiver.archivedData(withRootObject: updatedPlaces)
        userDefaults.set(data, forKey: key)
    }

    func prepareAllBusStopItems(allBusStops: [BusStop]) -> [ItemType] {
        var itemArray: [ItemType] = []
        for bus in allBusStops {
            itemArray.append(.busStop(BusStop(name: bus.name, lat: bus.lat, long: bus.long)))
        }
        return itemArray
    }

    func sectionIndexesForBusStop() -> [String: Int] {
        var sectionIndexDictionary: [String: Int] = [:]
        let allStops = SearchTableViewManager.shared.getAllStops()
        var currentChar: Character = Character("+")
        var currentIndex = 0
        for busStop in allStops {
            if let firstChar = busStop.name.capitalized.first {
                if currentChar != firstChar {
                    sectionIndexDictionary["\(firstChar)"] = currentIndex
                    currentChar = firstChar
                }
                currentIndex += 1
            }
        }
        return sectionIndexDictionary
    }
}




