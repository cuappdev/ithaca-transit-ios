//
//  AppDelegate.swift
//  TCAT
//
//  Created by Kevin Greer on 9/7/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import Firebase
import FutureNova
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
    private let userDataInits: [(key: String, defaultValue: Any)] = [
        (key: Constants.UserDefaults.onboardingShown, defaultValue: false),
        (key: Constants.UserDefaults.recentSearch, defaultValue: [Any]()),
        (key: Constants.UserDefaults.favorites, defaultValue: [Any]())
    ]
    private let networking: Networking = URLSession.shared.request

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set up networking
        Endpoint.setupEndpointConfig()

        // Set Up Google Services
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey(TransitEnvironment.googleMaps)

        // Update shortcut items
        AppShortcuts.shared.updateShortcutItems()

        // Log basic information
        let payload = AppLaunchedPayload()
        TransitAnalytics.shared.log(payload)
        setupUniqueIdentifier()

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

        // Track number of app opens for Store Review prompt
        StoreReviewHelper.incrementAppOpenedCount()

        // Debug - Always Show Onboarding
        // userDefaults.set(false, forKey: Constants.UserDefaults.onboardingShown)

        getBusStops()

        // Initalize first view based on context
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

    /// Creates and sets a unique identifier. If the device identifier changes, updates it.
    func setupUniqueIdentifier() {
        if let uid = UIDevice.current.identifierForVendor?.uuidString,
            uid != sharedUserDefaults?.string(forKey: Constants.UserDefaults.uid) {
            sharedUserDefaults?.set(uid, forKey: Constants.UserDefaults.uid)
        }
    }

    func handleShortcut(item: UIApplicationShortcutItem) {
        if let shortcutData = item.userInfo as? [String: Data] {
            guard let place = shortcutData["place"],
                let destination = try? decoder.decode(Place.self, from: place) else {
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

    private func getAllStops() -> Future<Response<[Place]>> {
        return networking(Endpoint.getAllStops()).decode()
    }

    /// Get all bus stops and store in userDefaults 
    func getBusStops() {
        getAllStops().observe { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .value(let response):
                    if response.data.isEmpty { self.handleGetAllStopsError() } else {
                        let encodedObject = try? JSONEncoder().encode(response.data)
                        userDefaults.set(encodedObject, forKey: Constants.UserDefaults.allBusStops)
                    }
                case .error(let error):
                    print("getBusStops error:", error.localizedDescription)
                    self.handleGetAllStopsError()
                }
            }
        }
    }

    /// Present an alert indicating bus stops weren't fetched.
    func handleGetAllStopsError() {
        let title = "Couldn't Fetch Bus Stops"
        let message = "The app will continue trying on launch. You can continue to use the app as normal."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.presentInApp(alertController)
    }

    /// Open the app when opened via URL scheme
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        // URLs for testing
        // BusStop: ithaca-transit://getRoutes?lat=42.442558&long=-76.485336&stopName=Collegetown
        // PlaceResult: ithaca-transit://getRoutes?lat=42.44707979999999&long=-76.4885196&destinationName=Hans%20Bethe%20House

        let rootVC = HomeMapViewController()
        let navigationController = CustomNavigationController(rootViewController: rootVC)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems

        if url.absoluteString.contains("getRoutes") { // siri URL scheme
            var latitude: CLLocationDegrees?
            var longitude: CLLocationDegrees?
            var stopName: String?

            if
                let lat = items?.filter({ $0.name == "lat" }).first?.value,
                let long = items?.filter({ $0.name == "long" }).first?.value,
                let stop = items?.filter({ $0.name == "stopName" }).first?.value {
                latitude = Double(lat)
                longitude = Double(long)
                stopName = stop
            }

            if let latitude = latitude, let longitude = longitude, let stopName = stopName {
                let place = Place(name: stopName, type: .busStop, latitude: latitude, longitude: longitude)
                let optionsVC = RouteOptionsViewController(searchTo: place)
                navigationController.pushViewController(optionsVC, animated: false)
                return true
            }
        }

        return false
    }

}

extension UIWindow {

    /// Find the visible view controller in the root navigation controller and present passed in view controlelr.
    func presentInApp(_ viewController: UIViewController) {
        (rootViewController as? UINavigationController)?.visibleViewController?.present(viewController, animated: true)
    }

}

extension AppDelegate {

//MessagingDelegate
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        self.firebaseToken = fcmToken!
//        print("Firebase token: \(fcmToken)")
//    }
    
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
