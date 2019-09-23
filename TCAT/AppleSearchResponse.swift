//
//  AppleSearchResponse.swift
//  TCAT
//
//  Created by Kevin Chan on 9/23/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Foundation

struct AppleSearchResponse: Codable {
    let applePlaces: [Place]?
    let busStops: [Place]
}
