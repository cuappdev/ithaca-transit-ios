//
//  AppDelegate.swift
//  TCAT
//
//  Created by Kevin Greer on 9/7/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import Combine
import Firebase
import GoogleMaps
import Intents
import SafariServices
import SwiftyJSON
import UIKit

/// This is used for app-specific preferences
let userDefaults = UserDefaults.standard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let encoder = JSONEncoder()
    private let transitService: TransitServiceProtocol = TransitService.shared

    private let userDataInits: [(key: String, defaultValue: Any)] = [
        (key: Constants.UserDefaults.onboardingShown, defaultValue: false),
        (key: Constants.UserDefaults.recentSearch, defaultValue: [Any]()),
        (key: Constants.UserDefaults.favorites, defaultValue: [Any]())
    ]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set Up Google Services
        FirebaseApp.configure()

        GMSServices.provideAPIKey(TransitEnvironment.googleMaps)

        // Update shortcut items
        AppShortcuts.shared.updateShortcutItems()

        // Log basic information
        let payload = AppLaunchedPayload()
        TransitAnalytics.shared.log(payload)
        setupUniqueIdentifier()

        // Initialize UserDefaults values if needed
        initializeUserDefaults()

        // Track number of app opens for Store Review prompt
        StoreReviewHelper.incrementAppOpenedCount()

        // Debug - Always Show Onboarding
        // userDefaults.set(false, forKey: Constants.UserDefaults.onboardingShown)

        // Initialize first view based on context
        let showOnboarding = !userDefaults.bool(forKey: Constants.UserDefaults.onboardingShown)
        let parentHomeViewController = ParentHomeMapViewController(
            contentViewController: HomeMapViewController(),
            drawerViewController: FavoritesViewController(isEditing: false)
        )
        let rootVC = showOnboarding ? OnboardingViewController(initialViewing: true) : parentHomeViewController
        let navigationController = showOnboarding ? OnboardingNavigationController(rootViewController: rootVC) :
        CustomNavigationController(rootViewController: rootVC)

        // Setup networking for AppDevAnnouncements
        // TODO: Set up announcements once it's done
        //        AnnouncementNetworking.setupConfig(
        //            scheme: TransitEnvironment.announcementsScheme,
        //            host: TransitEnvironment.announcementsHost,
        //            commonPath: TransitEnvironment.announcementsCommonPath,
        //            announcementPath: TransitEnvironment.announcementsPath
        //        )

        // Initalize window without storyboard
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcut(item: shortcutItem)
    }

    // MARK: - Helper Functions

    /// Initializes the UserDefaults values if not present
    private func initializeUserDefaults() {
        for (key, defaultValue) in userDataInits {
            if userDefaults.value(forKey: key) == nil {
                if key == Constants.UserDefaults.favorites && sharedUserDefaults?.value(forKey: key) == nil {
                    sharedUserDefaults?.set(defaultValue, forKey: key)
                } else {
                    userDefaults.set(defaultValue, forKey: key)
                }
            } else if key == Constants.UserDefaults.favorites && sharedUserDefaults?.value(forKey: key) == nil {
                sharedUserDefaults?.set(userDefaults.value(forKey: key), forKey: key)
            }
        }
    }

    /// Creates and sets a unique identifier. If the device identifier changes, updates it.
    private func setupUniqueIdentifier() {
        if let uid = UIDevice.current.identifierForVendor?.uuidString,
           uid != sharedUserDefaults?.string(forKey: Constants.UserDefaults.uid) {
            sharedUserDefaults?.set(uid, forKey: Constants.UserDefaults.uid)
        }
    }

    private func handleShortcut(item: UIApplicationShortcutItem) {
        if let shortcutData = item.userInfo as? [String: Data] {
            guard let place = shortcutData["place"],
                  let destination = try? JSONDecoder().decode(Place.self, from: place) else {
                print("[AppDelegate] Unable to access shortcutData['place']")
                return
            }
            let optionsVC = RouteOptionsViewController(searchTo: destination)
            if let navController = window?.rootViewController as? CustomNavigationController {
                navController.pushViewController(optionsVC, animated: false)
            }
            let payload = HomeScreenQuickActionUsedPayload(name: destination.name)
            TransitAnalytics.shared.log(payload)
        }
    }

    /// Open the app when opened via URL scheme
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        // URLs for testing
        // BusStop: ithaca-transit://getRoutes?lat=42.442558&long=-76.485336&stopName=Collegetown
        // PlaceResult: ithaca-transit://getRoutes?lat=42.4440892&long=-76.4847823&destinationName=Hollister%Hall&destinationType=applePlace

        let rootVC = HomeMapViewController()
        let navigationController = CustomNavigationController(rootViewController: rootVC)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        var placeType: PlaceType = .busStop

        if url.absoluteString.contains("getRoutes") {
            var latitude: CLLocationDegrees?
            var longitude: CLLocationDegrees?
            var destination: String?

            if let lat = items?.filter({ $0.name == "lat" }).first?.value,
               let long = items?.filter({ $0.name == "long" }).first?.value,
               let dest = items?.filter({ $0.name == "stopName" }).first?.value ??
                items?.filter({ $0.name == "destinationName" }).first?.value,
               let destType = items?.filter({ $0.name == "destinationType" }).first?.value {

                latitude = Double(lat)
                longitude = Double(long)
                destination = dest.split(separator: "%").joined(separator: " ")
                if destType == "applePlace" {
                    placeType = .applePlace
                }

            }

            if let latitude = latitude, let longitude = longitude, let destination = destination {
                let place = Place(name: destination, type: placeType, latitude: latitude, longitude: longitude)
                let optionsVC = RouteOptionsViewController(searchTo: place)
                navigationController.pushViewController(optionsVC, animated: false)
                return true
            }
        }

        return false
    }

}

extension UIWindow {

    /// Find the visible view controller in the root navigation controller and present passed in view controller.
    func presentInApp(_ viewController: UIViewController) {
        (rootViewController as? UINavigationController)?.visibleViewController?.present(viewController, animated: true)
    }

}
