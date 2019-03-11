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
    
    /// The saved app version in UserDefaults. This is manually updated on release.
    var savedAppVersion: WhatsNew.Version {
        let versionString = userDefaults.string(forKey: Constants.UserDefaults.version) ?? Constants.App.version
        return WhatsNew.Version(stringLiteral: versionString)
    }
    
    /// Returns true if update has been seen
    func has(version: WhatsNew.Version) -> Bool {
        return WhatsNew.Version.current() == savedAppVersion
    }

    func set(version: WhatsNew.Version) {
        userDefaults.set(Constants.App.version, forKey: Constants.UserDefaults.version)
    }
    
    func isNewCardAvailable() -> Bool {
        guard
            let whatsNewData = userDefaults.data(forKey: Constants.UserDefaults.whatsNewCardVersion),
            let storedWhatsNew = try? JSONDecoder().decode(WhatsNewCard.self, from: whatsNewData)
            else {
                return false
        }
        return !WhatsNewCard.newFeature.isEqual(to: storedWhatsNew)
    }
    
    func storeShownCard(card: WhatsNewCard) {
        if let encodedData = try? JSONEncoder().encode(card) {
            userDefaults.set(encodedData, forKey: Constants.UserDefaults.whatsNewCardVersion)
        } else {
            print("[VersionStore] Encoding Error")
        }
    }

}
