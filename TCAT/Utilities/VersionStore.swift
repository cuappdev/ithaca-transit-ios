//
//  VersionStore.swift
//  TCAT
//
//  Created by Omar Rasheed on 10/14/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import WhatsNewKit

class VersionStore: WhatsNewVersionStore {
    
    static let shared = VersionStore()
    
    /// The current app version, dynamically loaded based on bundle identifier.
    var currentAppVersion: WhatsNew.Version {
        return WhatsNew.Version(stringLiteral: Constants.App.version)
    }
    
    /// The saved app version in UserDefaults. This is manually updated on release.
    var savedAppVersion: WhatsNew.Version {
        let versionString = userDefaults.string(forKey: Constants.UserDefaults.version) ?? Constants.App.version
        return WhatsNew.Version(stringLiteral: versionString)
    }
    
    /// Returns true if update has been seen
    func has(version: WhatsNew.Version) -> Bool {
        if let whatsNewData = userDefaults.data(forKey: Constants.UserDefaults.whatsNewVersion),
            let storedWhatsNew = try? JSONDecoder().decode(WhatsNewCard.self, from: whatsNewData) {
            let isNotNewVersion = WhatsNewCard.current.isEqual(to: storedWhatsNew)
            return isNotNewVersion
        } else {
            print("[VersionStore] Decoding Error")
        }
        return false
    }

    func set(version: WhatsNew.Version) {
        if let encodedData = try? JSONEncoder().encode(WhatsNewCard.current) {
            userDefaults.set(encodedData, forKey: Constants.UserDefaults.whatsNewVersion)
        } else {
            print("[VersionStore] Encoding Error")
        }
        
    }

}
