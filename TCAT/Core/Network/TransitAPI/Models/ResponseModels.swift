//
//  ResponseModels.swift
//  TCAT
//
//  Created by Jayson Hahn on 2/17/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import Foundation

internal struct Delay: Codable {
    let tripID: String
    let delay: Int?
}

class RouteSectionsObject: Codable {
    var fromStop: [Route]
    var boardingSoon: [Route]
    var walking: [Route]
}
