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
        let rootVC: UIViewController = userDefaults.bool(forKey: "onboardingShown") ? HomeViewController() :
            OnboardViewController()
        let navigationController = UINavigationController(rootViewController: rootVC)
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = .black
        
        (rootVC as? HomeViewController)?.getBusStops()
     
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        if userDefaults.value(forKey: "recentSearch") == nil {
            userDefaults.set([Any](), forKey: "recentSearch")
        }
        
        Fabric.with([Crashlytics.self])
        #if DEBUG
            print ("DEBUG MODE")
        #else
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
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

