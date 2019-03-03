//
//  AppDelegate.swift
//  TCAT
//
//  Created by Kevin Greer on 9/7/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Fabric
import Crashlytics
import SafariServices
import WhatsNewKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let userDefaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let userDataInits: [(key: String, defaultValue: Any)] = [
        (key: Constants.UserDefaults.onboardingShown, defaultValue: false),
        (key: Constants.UserDefaults.recentSearch, defaultValue: [Any]()),
        (key: Constants.UserDefaults.favorites, defaultValue: [Any]()),
        (key: Constants.UserDefaults.whatsNewDismissed, defaultValue: false)
    ]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set Up Google Services
        FirebaseApp.configure()
        GMSServices.provideAPIKey(Keys.googleMaps.value)
        GMSPlacesClient.provideAPIKey(Keys.googlePlaces.value)
        
        migrationToNewPlacesModel()
        
        // Update shortcut items
        AppShortcuts.shared.updateShortcutItems()

        // Set Up Analytics
        #if !DEBUG
            Crashlytics.start(withAPIKey: Keys.fabricAPIKey.value)
        #endif

        // Log basic information
        let payload = AppLaunchedPayload()
        Analytics.shared.log(payload)
        setupUniqueIdentifier()
        JSONFileManager.shared.deleteAllJSONs()

        for (key, defaultValue) in userDataInits {
            if userDefaults.value(forKey: key) == nil {
                userDefaults.set(defaultValue, forKey: key)
            }
        }

        // Track number of app opens for Store Review prompt
        StoreReviewHelper.incrementAppOpenedCount()

        // Debug - Always Show Onboarding
        // userDefaults.set(false, forKey: Constants.UserDefaults.onboardingShown)

        getBusStops()

        // Initalize first view based on context
        let showOnboarding = !userDefaults.bool(forKey: Constants.UserDefaults.onboardingShown)
        let rootVC = showOnboarding ? OnboardingViewController(initialViewing: true) : HomeViewController()
        let navigationController = showOnboarding ? OnboardingNavigationController(rootViewController: rootVC) :
            CustomNavigationController(rootViewController: rootVC)

        // Initalize window without storyboard
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcut(item: shortcutItem)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here y/Users/mattbarker016ou can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: Helper Functions
    
    /// Convert BusStop and PlaceResult models to new unified Place model.
    func migrationToNewPlacesModel() {
        
        // Potentially check version to make sure this only fires once.
        
        //
        // allStops
        //
        
        // should overwrite existing values
        // getBusStops()
        
        //
        // favorites
        //
        
        let favoritesKey = Constants.UserDefaults.favorites
        
        if
            let storedPlaces = userDefaults.value(forKey: favoritesKey) as? Data,
            let favorites = NSKeyedUnarchiver.unarchiveObject(with: storedPlaces) as? [Any]
        {
            // This will only fire on legacy models
            convertDataToPlaces(data: favorites) { (places) in
                do {
                    let encodedObject = try self.encoder.encode(places)
                    self.userDefaults.set(encodedObject, forKey: favoritesKey)
                } catch let error {
                    print(error)
                }
            }
        }
        
        // Update shortcuts
        // Done in main AppDelegate.swift function
        
        //
        // recentSearches
        //
        
        let recentSearchesKey = Constants.UserDefaults.recentSearch
        
        //  This will only fire on legacy models
        if
            let storedPlaces = userDefaults.value(forKey: recentSearchesKey) as? Data,
            let recents = NSKeyedUnarchiver.unarchiveObject(with: storedPlaces) as? [Any]
        {
            convertDataToPlaces(data: recents) { (places) in
                do {
                    let encodedObject = try self.encoder.encode(places)
                    self.userDefaults.set(encodedObject, forKey: recentSearchesKey)
                } catch let error {
                    print(error)
                }
            }
        }
        
        // Should show a loading function until everything in here finishes. "Updating database"

    }
    
    func convertDataToPlaces(data: [Any], completion: @escaping (_ places: [Place]) -> Void) {
        var places = [Place]()
        for item in data {
            
            var place: Place!
            
            // Unwrap `Any` to `BusStop` or `PlaceResult`
            if let busStop = item as? BusStop {
                place = Place(name: busStop.name, latitude: busStop.lat, longitude: busStop.long)
            }
            if let placeResult = item as? PlaceResult {
                place = Place(name: placeResult.name, placeDescription: placeResult.detail, placeIdentifier: placeResult.placeID)
            }
            
            if place.type == .googlePlace {
                CoordinateVisitor.getCoordinates(for: place) { (latitude, longitude, error) in
                    if error != nil {
                        // TODO: Handle error properly
                        print("Unable to get coordinates to save favorite.")
                    } else {
                        place.latitude = latitude
                        place.longitude = longitude
                        places.append(place)
                    }
                    if places.count == data.count {
                        completion(places)
                    }
                }
            } else {
                places.append(place)
                if places.count == data.count {
                    completion(places)
                }
            }
            
        } // end for loop
        
    }
    
    /// Creates and sets a unique identifier. If the device identifier changes, updates it.
    func setupUniqueIdentifier() {
        if
            let uid = UIDevice.current.identifierForVendor?.uuidString,
            uid != userDefaults.string(forKey: Constants.UserDefaults.uid)
        {
            userDefaults.set(uid, forKey: Constants.UserDefaults.uid)
        }
    }
    
    func handleShortcut(item: UIApplicationShortcutItem) {
        let optionsVC = RouteOptionsViewController()
        if let shortcutData = item.userInfo as? [String: Data] {
            guard
                let place = shortcutData["place"],
                let destination = try? decoder.decode(Place.self, from: place)
            else {
                print("[AppDelegate] Unable to access shortcutData['place']")
                return
            }
            optionsVC.searchTo = destination
            if let navController = window?.rootViewController as? CustomNavigationController {
                navController.pushViewController(optionsVC, animated: false)
            }
            let payload = HomeScreenQuickActionUsedPayload(name: destination.name)
            Analytics.shared.log(payload)
        }
    }

    /* Get all bus stops and store in userDefaults */
    func getBusStops() {
        Network.getAllStops().perform(withSuccess: { allBusStopsRequest in
            let allBusStops = allBusStopsRequest.data
            if allBusStops.isEmpty {
                self.handleGetAllStopsError()
            } else {
                let encodedObject = try? JSONEncoder().encode(allBusStops)
                self.userDefaults.set(encodedObject, forKey: Constants.UserDefaults.allBusStops)
            }
        }, failure: { error in
            print("getBusStops error:", error)
            self.handleGetAllStopsError()
        })
    }

    func showWhatsNew(items: [WhatsNew.Item]) {
        let whatsNew = WhatsNew(
            title: "WhatsNewKit",
            // The features you want to showcase
            items: items
        )
        // Initialize WhatsNewViewController with WhatsNew
        let whatsNewViewController = WhatsNewViewController(
            whatsNew: whatsNew
        )

        // Present it 🤩
        UIApplication.shared.keyWindow?.presentInApp(whatsNewViewController)
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

        let rootVC = HomeViewController()
        let navigationController = CustomNavigationController(rootViewController: rootVC)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems

        if url.absoluteString.contains("getRoutes") {
            var latitude: CLLocationDegrees?
            var longitude: CLLocationDegrees?
            var stopName: String?
            let optionsVC = RouteOptionsViewController()

            if
                let lat = items?.filter({ $0.name == "lat" }).first?.value,
                let long = items?.filter({ $0.name == "long" }).first?.value,
                let stop = items?.filter({ $0.name == "stopName" }).first?.value {
                    latitude = Double(lat)
                    longitude = Double(long)
                    stopName = stop
                }

            if let latitude = latitude, let longitude = longitude, let stopName = stopName {
                let place = Place(name: stopName, latitude: latitude, longitude: longitude)
                optionsVC.searchTo = place
                navigationController.pushViewController(optionsVC, animated: false)
                return true
            }
        }

        return false
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        if #available(iOS 12.0, *) {
            if
                let intent = userActivity.interaction?.intent as? GetRoutesIntent,
                let latitude = intent.latitude,
                let longitude = intent.longitude,
                let searchTo = intent.searchTo,
                let stopName = searchTo.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                let url = URL(string: "ithaca-transit://getRoutes?lat=\(latitude)&long=\(longitude)&stopName=\(stopName)")
            {
                UIApplication.shared.open(url, options: [:]) { (didComplete) in
                    let intentDescription = userActivity.interaction?.intent.intentDescription ?? "No Intent Description"
                    let payload = SiriShortcutUsedPayload(didComplete: didComplete,
                                                               intentDescription: intentDescription,
                                                               locationName: stopName)
                    Analytics.shared.log(payload)
                }
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
