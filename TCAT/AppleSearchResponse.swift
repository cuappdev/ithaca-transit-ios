//
//  AppleSearchResponse.swift
//  TCAT
//
//  Created by Kevin Chan on 9/23/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Foundation

struct AppleSearchResponse: Codable {
    /// `applePlaces` is nil when the server does not have the list
    /// of ApplePlaces for the search query in its cache
    let applePlaces: [Place]?
    let busStops: [Place]
}
