//
//  AppDelegate.swift
//  TCAT
//
//  Created by Kevin Greer on 9/7/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Fabric
import Crashlytics
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    let userDefaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Set Up Google Services
        let json = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "config", withExtension: "json")!))
        GMSServices.provideAPIKey(json["google-maps"].stringValue)
        GMSPlacesClient.provideAPIKey(json["google-places"].stringValue)
        
        // userDefaults.set(false, forKey: "onboardingShown")
        if userDefaults.value(forKey: "onboardingShown") == nil {
            userDefaults.set(false, forKey: "onboardingShown")
        }
        
        // Initalize window without storyboard
        getBusStops()

        let rootVC = userDefaults.bool(forKey: "onboardingShown") ? HomeViewController() : OnboardViewController()
        let navigationController = CustomNavigationController(rootViewController: rootVC)

        UIApplication.shared.statusBarStyle = .default
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        if userDefaults.value(forKey: Key.UserDefaults.recentSearch) == nil {
            userDefaults.set([Any](), forKey: Key.UserDefaults.recentSearch)
        }
        if userDefaults.value(forKey: Key.UserDefaults.favorites) == nil {
            userDefaults.set([Any](), forKey: Key.UserDefaults.favorites)
        }

        
        #if DEBUG
            print ("DEBUG MODE")
        #else
            Fabric.with([Crashlytics.self])
            print ("RELEASE MODE")
        #endif
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("AppDelegate locationManager didFailWithError: \(error)")
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

    /* Get all bus stops and store in userDefaults */
    func getBusStops() {
        Network.getAllStops().perform(withSuccess: { stops in
            let allBusStops = stops.allStops
            let data = NSKeyedArchiver.archivedData(withRootObject: allBusStops)
            self.userDefaults.set(data, forKey: Key.UserDefaults.allBusStops)
        }, failure: { error in
            print("getBusStops error:", error)
        })
    }

    
    
}

extension UIWindow {
    
    open override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            let title = "Submit Beta Feedback"
            let message = "You can help us make our app even better! Take screenshots within the app and tap below to submit."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Submit Feedback", style: .default, handler: { _ in
                self.openFeedback()
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertController.addAction(action)
            alertController.addAction(cancel)
            presentInApp(alertController)
            
        }
    }
    
    func openFeedback() {
        let betaFormURL = "https://goo.gl/forms/u2shinl8ddNyFuZ23"
        let safariViewController = SFSafariViewController(url: URL(string: betaFormURL)!)
        presentInApp(safariViewController)
    }
    
    /// Find the visible view controller in the root navigation controller and present passed in view controlelr.
    func presentInApp(_ viewController: UIViewController) {
        (rootViewController as? UINavigationController)?.visibleViewController?.present(viewController, animated: true)
    }

}

