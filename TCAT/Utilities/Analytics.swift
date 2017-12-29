//
//  Analytics.swift
//  TCAT
//
//  Created by Serge-Olivier Amega on 12/29/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import SwiftRegister

fileprivate var registerSession: RegisterSession? = nil

extension RegisterSession {
    static var shared: RegisterSession {
        guard let session = registerSession else {
            guard let url = URL(string: "http://52.54.98.130/api/") else {
                fatalError("Invalid Url")
            }
            registerSession = RegisterSession(apiUrl: url, secretKey: "")
            return registerSession!
        }
        return session
    }
}

struct SearchBarTappedEventPayload: Payload {
    enum SearchBarTapLocation: String, Codable {
        case home
    }
    static let eventName: String = "searchBarTapped"
    let location: SearchBarTapLocation
}

struct DestinationSearchedEventPayload: Payload {
    static let eventName: String = "destinationSearched"
    let destination: String
    let requestUrl: String?
    let stopType: String?
}

struct RouteResultsCellTappedEventPayload: Payload {
    static let eventName: String = "tappedRouteResultsCell"
}
