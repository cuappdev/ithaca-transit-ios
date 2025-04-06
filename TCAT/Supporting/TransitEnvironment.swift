//
//  TransitEnvironment.swift
//  TCAT
//
//  Created by Vin Bui on 3/13/24.
//  Copyright © 2024 cuappdev. All rights reserved.
//

import Foundation

/// Data from Keys.plist stored as environment variables.
enum TransitEnvironment {

    /// Keys from Keys.plist.
    enum Keys {
#if DEBUG
        static let eateryURL = "EATERY_DEV_URL"
        static let googleMaps = "GOOGLE_MAPS_DEBUG"
        static let transitURL = "TRANSIT_PROD_URL"
        static let upliftURL = "UPLIFT_DEV_URL"
#else
        static let eateryURL = "EATERY_PROD_URL"
        static let googleMaps = "GOOGLE_MAPS_RELEASE"
        static let transitURL = "TRANSIT_PROD_URL"
        static let upliftURL = "UPLIFT_PROD_URL"
#endif
        static let announcementsCommonPath = "ANNOUNCEMENTS_COMMON_PATH"
        static let announcementsHost = "ANNOUNCEMENTS_HOST"
        static let announcementsPath = "ANNOUNCEMENTS_PATH"
        static let announcementsScheme = "ANNOUNCEMENTS_SCHEME"
        
        // TODO: Remove once the Notifications moves to prod
        static let devTransitURL = "TRANSIT_DEV_URL"
    }

    /// A dictionary storing key-value pairs from Keys.plist.
    private static let keysDict: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("Keys.plist not found")
        }
        return dict
    }()

    /**
     The base URL of Transit's backend server.

     * If the scheme is set to DEBUG, the development server URL is used.
     * If the scheme is set to RELEASE, the production server URL is used.
     */
    static let transitURL: String = {
        guard let baseURLString = TransitEnvironment.keysDict[Keys.transitURL] as? String else {
#if DEBUG
            fatalError("TRANSIT_DEV_URL not found in Keys.plist")
#else
            fatalError("TRANSIT_PROD_URL not found in Keys.plist")
#endif
        }
        return baseURLString
    }()

    // TODO: Remove once Notifications moves to prod
    static let devTransitURL: String = {
        guard let baseURLString = TransitEnvironment.keysDict[Keys.devTransitURL] as? String else {
            fatalError("TRANSIT_DEV_URL not found in Keys.plist")
        }
        return baseURLString
    }()

    /**
     The base URL of Uplift's backend server.

     * If the scheme is set to DEBUG, the development server URL is used.
     * If the scheme is set to RELEASE, the production server URL is used.
     */
    static let upliftURL: String = {
        guard let baseURLString = TransitEnvironment.keysDict[Keys.upliftURL] as? String else {
#if DEBUG
            fatalError("UPLIFT_DEV_URL not found in Keys.plist")
#else
            fatalError("UPLIFT_PROD_URL not found in Keys.plist")
#endif
        }
        return baseURLString
    }()

    /**
     The base URL of Eatery's backend server.

     * If the scheme is set to DEBUG, the development server URL is used.
     * If the scheme is set to RELEASE, the production server URL is used.
     */
    static let eateryURL: String = {
        guard let baseURLString = TransitEnvironment.keysDict[Keys.eateryURL] as? String else {
#if DEBUG
            fatalError("EATERY_DEV_URL not found in Keys.plist")
#else
            fatalError("EATERY_PROD_URL not found in Keys.plist")
#endif
        }
        return baseURLString
    }()

    /// The common path for AppDev Announcements.
    static let announcementsCommonPath: String = {
        guard let value = TransitEnvironment.keysDict[Keys.announcementsCommonPath] as? String else {
            fatalError("ANNOUNCEMENTS_COMMON_PATH not found in Keys.plist")
        }
        return value
    }()

    /// The host for AppDev Announcements.
    static let announcementsHost: String = {
        guard let value = TransitEnvironment.keysDict[Keys.announcementsHost] as? String else {
            fatalError("ANNOUNCEMENTS_HOST not found in Keys.plist")
        }
        return value
    }()

    /// The path for AppDev Announcements.
    static let announcementsPath: String = {
        guard let value = TransitEnvironment.keysDict[Keys.announcementsPath] as? String else {
            fatalError("ANNOUNCEMENTS_PATH not found in Keys.plist")
        }
        return value
    }()

    /// The scheme for AppDev Announcements.
    static let announcementsScheme: String = {
        guard let value = TransitEnvironment.keysDict[Keys.announcementsScheme] as? String else {
            fatalError("ANNOUNCEMENTS_SCHEME not found in Keys.plist")
        }
        return value
    }()

    /**
     The Google Maps API key.

     * If the scheme is set to DEBUG, the development key is used.
     * If the scheme is set to RELEASE, the production key is used.
     */
    static let googleMaps: String = {
        guard let value = TransitEnvironment.keysDict[Keys.googleMaps] as? String else {
#if DEBUG
            fatalError("GOOGLE_MAPS_DEBUG not found in Keys.plist")
#else
            fatalError("GOOGLE_MAPS_RELEASE not found in Keys.plist")
#endif
        }
        return value
    }()

}
