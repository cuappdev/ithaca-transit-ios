//
//  Analytics.swift
//  TCAT
//
//  Created by Serge-Olivier Amega on 12/29/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
// To log an event, use the shared RegisterSession (RegisterSession.shared)

import FirebaseAnalytics
import Foundation
import SwiftyJSON

class TransitAnalytics {

    static let shared = TransitAnalytics()

    func log(_ payload: Payload) {
        #if !DEBUG
            let analyticsEnabled = UserDefaults.standard.bool(forKey: Constants.UserDefaults.isAnalyticsEnabled)
            if analyticsEnabled {
                let fabricEvent = payload.convertToFabric()
                Analytics.logEvent(fabricEvent.name, parameters: fabricEvent.attributes)
            }
        #endif
            let analyticsEnabled = UserDefaults.standard.bool(forKey: Constants.UserDefaults.isAnalyticsEnabled)
            if analyticsEnabled {
                print("I'm analysing you!")
            } else {
                print("No analysis")
            }
    }

}

extension Payload {

    func convertToFabric() -> (name: String, attributes: [String: Any]?) {

        let event = self.toEvent()

        do {
            let data = try event.serializeJson()
            let json = try JSON(data: data)

            var dict: [String: Any] = [:]
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

    var model: String = UIDevice.current.modelName
    var softwareVersion: String = UIDevice.current.systemVersion
    var appVersion: String = Constants.App.version
    var language: String = Locale.preferredLanguages.first ?? "n/a"

}

// MARK: - Event Payloads

// MARK: - Important
/// Log app launch with device info
struct AppLaunchedPayload: Payload {
    static let eventName: String = "App Launched"
    var deviceInfo = DeviceInfo()
}

/// Log favorites that a user adds
struct FavoriteAddedPayload: Payload {
    static let eventName: String = "Favorite Added"
    var deviceInfo = DeviceInfo()

    let name: String
}

/// Log when a user selects a Google Place
struct PlaceSelectedPayload: Payload {
    static let eventName: String = "Place Selected"
    var deviceInfo = DeviceInfo()

    let name: String
    let type: PlaceType
}

/// Log front end route calculation
struct DestinationSearchedEventPayload: Payload {
    static let eventName: String = "Destination Searched"
    var deviceInfo = DeviceInfo()

    let destination: String
}

/// Log tap on route leading to Route Detail view
struct RouteResultsCellTappedEventPayload: Payload {
    static let eventName: String = "Opened Route Detail View"
    var deviceInfo = DeviceInfo()
}

/// Log 3D touch Peek / Pop
struct RouteResultsCellPeekedPayload: Payload {
    static let eventName: String = "Route Results Cell Peeked"
}

/// Log opening of About page (settings page)
struct SettingsPageOpenedPayload: Payload {
    static let eventName: String = "Settings Page Opened"
    var deviceInfo = DeviceInfo()
}

/// Log opening of Settings about page
struct SettingsAboutPageOpenedPayload: Payload {
    static let eventName: String = "Settings About Page Opened"
    var deviceInfo = DeviceInfo()
}

/// Log opening of Settings Notif/Privacy page
struct SettingsNotifPrivacyPageOpenedPayload: Payload {
    static let eventName: String = "Settings Notifications & Privacy Page Opened"
    var deviceInfo = DeviceInfo()
}

/// Log opening of Settings Support page
struct SettingsSupportPageOpenedPayload: Payload {
    static let eventName: String = "Settings Support Page Opened"
    var deviceInfo = DeviceInfo()
}

/// Log big blue bus tap
struct BusTappedEventPayload: Payload {
    static let eventName: String = "Tapped Big Blue Bus"
    var deviceInfo = DeviceInfo()
}

/// Log route sharing
struct RouteSharedEventPayload: Payload {
    static let eventName: String = "Share Route"
    var deviceInfo = DeviceInfo()

    let activityType: String
    let didSelectAndCompleteShare: Bool
    let error: String?
}

/// Log any errors when sending feedback
struct FeedbackErrorPayload: Payload {
    static let eventName: String = "Feedback Error"
    var deviceInfo = DeviceInfo()

    let description: String
}

/// Log any errors when sending feedback
struct RouteOptionsSettingsPayload: Payload {
    static let eventName: String = "Route Options Changed"
    var deviceInfo = DeviceInfo()

    let description: String
}

/// Screenshot taken within app
struct ScreenshotTakenPayload: Payload {
    static let eventName: String = "Screenshot Taken"
    var deviceInfo = DeviceInfo()

    let location: String
}

/// App Shortcut used with 3D Touch from the Home Screen
struct HomeScreenQuickActionUsedPayload: Payload {
    static let eventName: String = "Home Screen Quick Action Used"
    var deviceInfo = DeviceInfo()

    let name: String
}

struct SiriShortcutUsedPayload: Payload {
    static let eventName: String = "Siri Shortcut used"
    var deviceInfo = DeviceInfo()

    let didComplete: Bool
    let intentDescription: String
    let locationName: String
}

struct DataMigrationOnePointThreePayload: Payload {
    static let eventName: String = "v1.2.2 Data Migration"
    var deviceInfo = DeviceInfo()

    let success: Bool
    let errorDescription: String?
}

struct ServiceAlertsPayload: Payload {
    static let eventName: String = "Service Alerts Opened"
    var deviceInfo = DeviceInfo()
}

struct PrimaryActionTappedPayload: Payload {
    static let eventName: String = "Primary Action Tapped"
    var deviceInfo = DeviceInfo()

    let actionDescription: String
}

struct SecondaryActionTappedPayload: Payload {
    static let eventName: String = "Secondary Action Tapped"
    var deviceInfo = DeviceInfo()

    let actionDescription: String
}

/// Log any network error
struct NetworkErrorPayload: Payload {
    static let eventName: String = "Network Error"
    var deviceInfo = DeviceInfo()

    let location: String
    let type: String
    let description: String
}

/// Log selected place's index in search
struct SearchResultSelectedPayload: Payload {
    static let eventName: String = "Search Result Selected"
    let searchText: String
    let selectedIndex: Int
    let totalResults: Int
}

/// Log whenever an announcement is presented to the user
struct AnnouncementPresentedPayload: Payload {
    static let eventName = "announcement_presented"
}
