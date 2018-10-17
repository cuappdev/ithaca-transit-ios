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
    /// Returns true if update has been seen
    func has(version: WhatsNew.Version) -> Bool {
        var isNotNewVersion = false
        let isVersionPatch = version.patch > 3
        if let appVersion = userDefaults.string(forKey: Constants.UserDefaults.version) {
            isNotNewVersion = version == WhatsNew.Version(stringLiteral: appVersion)
        }
        print (isNotNewVersion)
        return isVersionPatch || isNotNewVersion
    }

    func set(version: WhatsNew.Version) {
        userDefaults.set(Constants.App.version, forKey: Constants.UserDefaults.version)
    }

}
