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
        let favorites = SearchTableViewManager.shared.retrieveRecentPlaces(for: Constants.UserDefaults.favorites)
        var shortcutItems = [UIApplicationShortcutItem]()
        for itemType in favorites {
            switch itemType {
            case .busStop(let bustStop):
                shortcutItems.append(shortcutItem(for: bustStop))
            case .placeResult(let placeResult):
                shortcutItems.append(shortcutItem(for: placeResult))
            default: break
            }
        }
        UIApplication.shared.shortcutItems = shortcutItems
    }

    func shortcutItem(for place: Place) -> UIApplicationShortcutItem {
        let data = NSKeyedArchiver.archivedData(withRootObject: place)
        let placeInfo: [AnyHashable: Any] = ["place": data]
        let shortcutItem = UIApplicationShortcutItem(type: place.name, localizedTitle: place.name, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .favorite), userInfo: placeInfo)
        return shortcutItem
    }
}
