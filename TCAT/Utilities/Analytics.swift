//
//  Analytics.swift
//  TCAT
//
//  Created by Serge-Olivier Amega on 12/29/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
// To log an event, use the shared RegisterSession (RegisterSession.shared)

import Foundation
import SwiftyJSON
import Crashlytics


class Analytics {
    static let shared = Analytics()
    
    func log(_ payload: Payload) {
        let fabricEvent = payload.convertToFabric()
        Answers.logCustomEvent(withName: fabricEvent.name, customAttributes: fabricEvent.attributes)
        print("Logging \(fabricEvent.name):", fabricEvent.attributes ?? [:])
    }
}

extension Payload {
    
    func convertToFabric() -> (name: String, attributes: [String : Any]?) {
        
        let event = self.toEvent()
        
        do {
            let data = try event.serializeJson()
            let json = try JSON(data: data)
            
            var dict: [String : Any] = [:]
            for (key, value) in json["payload"] {
                if key == "deviceInfo" {
                    for (infoKey, infoValue) in value {
                        dict[infoKey] = infoValue.stringValue
                    }
                } else {
                    dict[key] = value.stringValue
                }
            }
            
            return(name: json["event_type"].stringValue, dict)
            
        } catch {
            print("Error: Couldn't process data")
            return ("", nil)
        }
        
    }
    
}

/// Log device information
struct DeviceInfo: Codable {
    
    let model: String = UIDevice.current.modelName
    let softwareVersion: String = UIDevice.current.systemVersion
    let appVersion: String = Constants.App.version
    let language: String = Locale.preferredLanguages.first ?? "n/a"
    
}

// MARK: Event Payloads

// MARK: Important
/// Log app launch with device info
struct AppLaunchedPayload: Payload {
    static let eventName: String = "App Launched"
    let deviceInfo = DeviceInfo()
}

/// Log favorites that a user adds
struct FavoriteAddedPayload: Payload {
    static let eventName: String = "Favorite Added"
    let deviceInfo = DeviceInfo()
    
    let name: String
}

/// Log when a user specfically used a bus stop
struct BusStopTappedPayload: Payload {
    static let eventName: String = "Bus Stop Selected"
    let deviceInfo = DeviceInfo()
    
    let name: String
}

/// Log when a user selects a Google Place
struct GooglePlaceTappedPayload: Payload {
    static let eventName: String = "Google Place Selected"
    let deviceInfo = DeviceInfo()
    
    let name: String
}

/// Log front end route calculation
struct DestinationSearchedEventPayload: Payload {
    static let eventName: String = "Destination Searched"
    let deviceInfo = DeviceInfo()
    
    let destination: String
    let requestUrl: String?
}

/// Log tap on route leading to Route Detail view
struct RouteResultsCellTappedEventPayload: Payload {
    static let eventName: String = "Opened Route Detail View"
    let deviceInfo = DeviceInfo()
}

/// Log 3D touch Peek / Pop
struct RouteResultsCellPeekedPayload: Payload {
    static let eventName: String = "Route Results Cell Peeked"
}

/// Log opening of About page
struct AboutPageOpenedPayload: Payload {
    static let eventName: String = "About Page Opened"
    let deviceInfo = DeviceInfo()
}

/// Log big blue bus tap
struct BusTappedEventPayload: Payload {
    static let eventName: String = "Tapped Big Blue Bus"
    let deviceInfo = DeviceInfo()
}

/// Log route sharing
struct RouteSharedEventPayload: Payload {
    static let eventName: String = "Share Route"
    let deviceInfo = DeviceInfo()
    
    let activityType: String
    let didSelectAndCompleteShare: Bool
    let error: String?
}

/// Log any errors when calculating routes
struct GetRoutesErrorPayload: Payload {
    static let eventName: String = "Get Routes Error"
    let deviceInfo = DeviceInfo()
    
    let type: String
    let description: String
    let url: String?
}

/// Log any errors when sending feedback
struct FeedbackErrorPayload: Payload {
    static let eventName: String = "Feedback Error"
    let deviceInfo = DeviceInfo()
    
    let description: String
}

/// Log any errors when sending feedback
struct RouteOptionsSettingsPayload: Payload {
    static let eventName: String = "Route Options Changed"
    let deviceInfo = DeviceInfo()
    
    let description: String
}

/// Screenshot taken within app
struct ScreenshotTakenPayload: Payload {
    static let eventName: String = "Screenshot Taken"
    let deviceInfo = DeviceInfo()
    
    let location: String
}

struct HomeScreenQuickActionUsedPayload: Payload {
    static let eventName: String = "Home Screen Quick Action Used"
    let deviceInfo = DeviceInfo()
    
    let name: String
}
