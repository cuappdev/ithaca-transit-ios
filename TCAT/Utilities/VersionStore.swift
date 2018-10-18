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
        let isVersionPatch = version.patch > 0
        let savedAppVersion = userDefaults.string(forKey: Constants.UserDefaults.version) ?? Constants.App.version
        let isNotNewVersion = (Constants.App.version == savedAppVersion)

        set(version: WhatsNew.Version.current())
        return isVersionPatch || isNotNewVersion
    }

    func set(version: WhatsNew.Version) {
        userDefaults.set(Constants.App.version, forKey: Constants.UserDefaults.version)
    }

}
