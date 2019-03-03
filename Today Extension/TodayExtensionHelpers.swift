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

    func retrieveFavoritesNames(for key: String) -> [String] {
        if let storedFavorites = sharedUserDefaults?.value(forKey: key) as? Data {
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

    func retrieveFavoritesCoordinates(for key: String, callback: @escaping([String: String]) -> Void) {

        if let storedFavorites = sharedUserDefaults?.value(forKey: key) as? Data {
            NSKeyedUnarchiver.setClass(PlaceResult.self, forClassName: "TCAT.PlaceResult")
            NSKeyedUnarchiver.setClass(BusStop.self, forClassName: "TCAT.BusStop")

            if let places = NSKeyedUnarchiver.unarchiveObject(with: storedFavorites) as? [Any] {

                var coordinates: [String: String] = [:]
                let visitor = CoordinateVisitor()
                let group = DispatchGroup()

                for place in places {
                    group.enter()
                    if let busStop = place as? BusStop {
                        let busStopPlace = busStop as Place
                        visitor.getCoordinate(from: busStop) { (coord, _) in
                            if let lat = coord?.latitude, let long = coord?.longitude {
                                coordinates.updateValue("\(lat),\(long)", forKey: busStopPlace.name)
                            }
                            group.leave()
                        }
                    }

                    if let placeResult = place as? PlaceResult {
                        let placeResultPlace = placeResult as Place
                        visitor.getCoordinate(from: placeResult) { (coord, _) in
                            if let lat = coord?.latitude, let long = coord?.longitude {
                                coordinates.updateValue("\(lat),\(long)", forKey: placeResultPlace.name)
                            }
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    callback(coordinates)
                }
            } else {
                print("Failed to retreive favorites' coordinates from User Defaults")
            }
        }
    }

    func orderCoordinates(favorites: [String], dictionary: [String: String]) -> [String] {
        var coordinates: [String] = []
        for place in favorites {
            if let coord = dictionary[place] {
                coordinates.append(coord)
            }
        }
        return coordinates
    }
}

//            var coordinates: [String] = []
//
//            do {
//                if let places = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, BusStop.self, PlaceResult.self], from: storedFavorites) as? [Any] {
//                    for place in places {
//                        if let busStop = place as? BusStop {
//                            let lat = String(busStop.lat)
//                            let long = String(busStop.long)
//                            coordinates.append("\(lat),\(long)")
//                        }
//                        if let searchResult = place as? PlaceResult {
//                            let visitor = CoordinateVisitor()
//                            visitor.getCoordinate(from: searchResult) { (coord, error) in
//                                if let lat = coord?.latitude, let long = coord?.longitude {
//                                    coordinates.append("\(lat),\(long)")
//                                }
//                            }
//                        }
//                    }
//                }
//            } catch {
//                print(error)
//            }
//
//            return coordinates
