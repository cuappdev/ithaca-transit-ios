//
//  Analytics.swift
//  TCAT
//
//  Created by Serge-Olivier Amega on 12/29/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
// To log an event, use the shared RegisterSession (RegisterSession.shared)

import Foundation
import SwiftRegister
import SwiftyJSON

fileprivate var registerSession: RegisterSession? = nil

fileprivate func getSecretKey() -> String? {
    let configUrl = Bundle.main.url(forResource: "config", withExtension: "json")!
    let configJson = try! JSON(Data(contentsOf: configUrl))
    return configJson["register-secret"].string
}

extension RegisterSession {
    static var shared: RegisterSession? {
        guard let session = registerSession else {
            let url = URL(string: "http://52.54.98.130/api/")!
            guard let secretKey = getSecretKey() else {
                print("could not initialize register session. missing secret key.")
                return nil
            }
            registerSession = RegisterSession(apiUrl: url, secretKey: secretKey)
            return registerSession
        }
        return session
    }
}

// MARK: Event Payloads

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

struct InformationViewControllerTappedEventPayload: Payload {
    static let eventName: String = "tappedBigBlueBus"
}

struct RouteSharedEventPayload: Payload {
    static let eventName: String = "routeShared"
    let activityType: String
    let didSelectAndCompleteShare: Bool
    let error: String?
}
