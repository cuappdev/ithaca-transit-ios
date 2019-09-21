//
//  SearchCache.swift
//  TCAT
//
//  Created by Kevin Chan on 9/20/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Foundation

class SearchPlacesCache {

    static let shared = SearchPlacesCache()

    private var queryToPlacesDict: [String: [Place]] = [:]

    private init() {}

    func put(query: String, places: [Place]) {
        queryToPlacesDict[query] = places
    }

    func get(query: String) -> [Place]? {
        return queryToPlacesDict[query]
    }

}
