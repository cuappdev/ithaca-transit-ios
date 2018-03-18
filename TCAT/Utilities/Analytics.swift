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
import PromiseKit
import Crashlytics

fileprivate var registerSession: RegisterSession? = nil

fileprivate func getSecretKey() -> String {
    let configURL = Bundle.main.url(forResource: "config", withExtension: "json")!
    let configJSON = try! JSON(Data(contentsOf: configURL))
    return configJSON["register-secret"].stringValue
}

extension RegisterSession {
    
    static let endpoint: String = "18.232.90.215"
    
    static var isLogging: Bool = false
    
    static var shared: RegisterSession? {
        
        if !isLogging {
            return nil
        }
        
        guard let session = registerSession else {
            let url = URL(string: "http://\(endpoint)/api/")!
            let secretKey = getSecretKey()
            registerSession = RegisterSession(apiUrl: url, secretKey: secretKey)
            return registerSession!
        }
        return session
        
    }
    
    static func startLogging() {
        isLogging = true
    }
    
    // Log events to both Fabric and Register
    func log(_ payload: Payload) {
        
        // let registerEvent = payload.toEvent()
        // logEvent(event: registerEvent)
        
        let fabricEvent = payload.convertToFabric()
        print("dict", fabricEvent.attributes ?? [:])
        Answers.logCustomEvent(withName: fabricEvent.name, customAttributes: fabricEvent.attributes)
        
        print("Log \(fabricEvent.name)")
        
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
                        dict[infoKey] = infoValue
                    }
                } else {
                    dict[key] = value
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

// MARK: Important
/// Log front end route calculation
struct DestinationSearchedEventPayload: Payload {
    static let eventName: String = "Destination Searched"
    static let deviceInfo = DeviceInfo()
    
    let destination: String
    let requestUrl: String?
    let stopType: String?
}

/// Log tap on route leading to Route Detail view
struct RouteResultsCellTappedEventPayload: Payload {
    static let eventName: String = "Opened Route Detail View"
    static let deviceInfo = DeviceInfo()
}

/// Log 3D touch Peek / Pop
struct RouteResultsCellPeekedPayload: Payload {
    static let eventName: String = "Route Results Cell Peeked"
}

/// Log use of date picker in Route Options
struct DatePickerAccessedPayload: Payload {
    static let eventName: String = "Date Picker Accessed"
}

/// Log opening of About page
struct AboutPageOpenedPayload: Payload {
    static let eventName: String = "About Page Opened"
    static let deviceInfo = DeviceInfo()
}

/// Log big blue bus tap
struct BusTappedEventPayload: Payload {
    static let eventName: String = "Tapped Big Blue Bus"
    static let deviceInfo = DeviceInfo()
}

/// Log route sharing
struct RouteSharedEventPayload: Payload {
    static let eventName: String = "Share Route"
    static let deviceInfo = DeviceInfo()
    
    let activityType: String
    let didSelectAndCompleteShare: Bool
    let error: String?
}

// Log any errors when calculation routes
struct GetRoutesErrorPayload: Payload {
    static let eventName: String = "Get Routes Error"
    static let deviceInfo = DeviceInfo()
    
    let description: String
    let url: String?
}
