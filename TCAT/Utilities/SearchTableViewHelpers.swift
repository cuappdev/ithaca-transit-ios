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
}

enum ItemType {
    case busStop(BusStop)
    case placeResult(PlaceResult)
    case cornellDestination
    case seeAllStops
}

func retrieveRecentLocations() -> [ItemType] {
    if let recentLocations = userDefaults.value(forKey: Key.UserDefaults.recentSearch) as? Data {
        let recentSearches = NSKeyedUnarchiver.unarchiveObject(with: recentLocations) as! [Any]
        var itemTypes: [ItemType] = []
        for search in recentSearches {
            if let busStop = search as? BusStop {
                itemTypes.append(.busStop(busStop))
            }
            if let searchResult = search as? PlaceResult {
                itemTypes.append(.placeResult(searchResult))
            }
        }
        return itemTypes
    }
    return [ItemType]()
}

func insertRecentLocation(location: Any) {
    let recentLocationsItemTypes = retrieveRecentLocations()
    let convertedRecentLocations = recentLocationsItemTypes.map( { item -> Any in
        switch item {
        case .busStop(let busStop): return busStop
        case .placeResult(let placeResult): return placeResult
        default: return "this shouldn't ever fire"
        }
    })
    let filteredLocations = location is BusStop ? convertedRecentLocations.filter({ !areObjectsEqual(type: BusStop.self, a: location, b: $0)}) : convertedRecentLocations.filter({ !areObjectsEqual(type: PlaceResult.self, a: location, b: $0)})
    
    var updatedRecentLocations = [location] + filteredLocations
    if updatedRecentLocations.count > 8 { updatedRecentLocations.remove(at: updatedRecentLocations.count - 1)}
    let data = NSKeyedArchiver.archivedData(withRootObject: updatedRecentLocations)
    userDefaults.set(data, forKey: Key.UserDefaults.recentSearch)
}

func getAllBusStops() -> [BusStop] {
    if let allBusStops = userDefaults.value(forKey: Key.UserDefaults.allBusStops) as? Data,
        let busStopArray = NSKeyedUnarchiver.unarchiveObject(with: allBusStops) as? [BusStop] {
            return busStopArray
    }
    return [BusStop]()
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
    let allStops = getAllBusStops()
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

func parseGoogleJSON(searchText: String, json: JSON) -> Section {
    
    var itemTypes: [ItemType] = []

    //dont keep calling getAllBusStops()
    let busStopsWithLevenshtein: [(BusStop, Int)] = getAllBusStops().map({ ($0, String.fuzzPartialRatio(str1: $0.name.lowercased(), str2: searchText.lowercased())) })
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




