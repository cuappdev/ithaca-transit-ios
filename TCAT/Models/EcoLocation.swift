//
//  EcoLocation.swift
//  TCAT
//
//  Created by Jayson Hahn on 4/30/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation

struct EcoLocation {
    var facility: Facility

    // Computed property to get the type of facility
    var status: EateryStatus 
}

enum Facility {
    case eatery(Eatery)
    case gym(Gym)
}
