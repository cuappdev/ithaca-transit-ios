//
//  AppShortcuts.swift
//  TCAT
//
//  Created by Omar Rasheed on 9/16/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

class AppShortcuts {

    static let shared = AppShortcuts()

    func updateShortcutItems() {
        let favorites = Global.shared.retrievePlaces(for: Constants.UserDefaults.favorites)
        let shortcutItems: [UIApplicationShortcutItem] = favorites.compactMap { (place) -> UIApplicationShortcutItem? in
            do {
                let data = try encoder.encode(place)
                let placeInfo: [String: Data] = ["place": data]
                return UIApplicationShortcutItem(
                    type: place.name,
                    localizedTitle: place.name,
                    localizedSubtitle: nil,
                    icon: UIApplicationShortcutIcon(type: .favorite),
                    userInfo: placeInfo as [String: NSSecureCoding]
                )
            } catch let error {
                print(error)
                return nil
            }
        }

        UIApplication.shared.shortcutItems = shortcutItems
    }

}
