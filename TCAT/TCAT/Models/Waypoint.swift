//
//  Waypoint.swift
//  TCAT
//
//  Created by Annie Cheng on 2/24/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import UIKit

class Waypoint: NSObject {
    
    var lat: CGFloat
    var long: CGFloat
    
    init(lat: CGFloat, long: CGFloat) {
        self.lat = lat
        self.long = long
        
    }
    
}

