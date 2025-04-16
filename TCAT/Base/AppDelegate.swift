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
import FirebaseMessaging

/// This is used for app-specific preferences
let userDefaults = UserDefaults.standard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

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

        // Initialize uid in UserDefaults values if needed
        userDefaults.setupUniqueIdentifier()

        // Initialize UserDefaults values if needed
        userDefaults.initialize(with: userDataInits)

        // Track number of app opens for Store Review prompt
        StoreReviewHelper.incrementAppOpenedCount()

        // Debug - Always Show Onboarding
        // userDefaults.set(false, forKey: Constants.UserDefaults.onboardingShown)

        // Initialize first view based on context
        let showOnboarding = !userDefaults.bool(forKey: Constants.UserDefaults.onboardingShown)
        let parentHomeViewController = ParentHomeMapViewController(
            contentViewController: HomeMapViewController(),
//            drawerViewController: FavoritesViewController(isEditing: false)
            drawerViewController: EcosystemViewController()
        )
        let rootVC = showOnboarding ? OnboardingViewController(initialViewing: true) : parentHomeViewController
        let navigationController = showOnboarding ? OnboardingNavigationController(rootViewController: rootVC) :
        CustomNavigationController(rootViewController: rootVC)

        // Initalize window without storyboard
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        //Set up notifications
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcut(item: shortcutItem)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                
            }
        }
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("application didFailToRegisterForRemoteNotificationsWithError")
    }

    // MARK: - Helper Functions

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
        // BusStop: ithaca-transit://getRoutes?lat=42.442558&long=-76.485336&stopName=Collegetown&destinationType=busStop
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

            if let latitude, let longitude, let destination {
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

extension AppDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    //UNUserNotificationCenterDelegate
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            print("APNs received with: \(userInfo)")
        }

}
