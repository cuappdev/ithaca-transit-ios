//
//  Crashlytics.swift
//  TCAT
//
//  Created by Ji Hwan Seung on 01/11/2017.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics

extension Answers {
    
    static func searchBarTappedInHome() {
        Answers.logCustomEvent(withName: "Search bar used in home", customAttributes: nil)
    }
    
    static func destinationSearched(destination: String, stopType: String? = "", requestUrl: String? = "") {
        Answers.logCustomEvent(withName: "Destination searched", customAttributes: ["destination": destination, "stop type": stopType, "request url": requestUrl])
    }
    
    static func userTappedRouteResultsCell() {
        Answers.logCustomEvent(withName: "Tapped route results cell", customAttributes: nil)
    }
}
