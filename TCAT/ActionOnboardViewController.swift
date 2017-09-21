//
//  ActionOnboardViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 9/20/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation

enum OnboardType: String {
    case locationServices, welcome
}

class ActionOnboardViewController: UIViewController, CLLocationManagerDelegate {
    
    var type: OnboardType!
    
    var locationManager = CLLocationManager()
    
    init(type: OnboardType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        self.view.backgroundColor = .purple
        
        createView()
        
    }
    
    func createView() {
        
        let spacing: CGFloat = 16
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 18)
        title.text = getTitle()
        title.center = view.center
        title.sizeToFit()
        view.addSubview(title)
        
        let description = UITextView()
        description.text = getDescription()
        description.center = view.center
        description.sizeToFit()
        description.frame.origin.y = title.frame.maxX + spacing
        view.addSubview(description)
        
        let button = UIButton()
        button.titleLabel?.text = getButtonText()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.backgroundColor = .buttonColor
        button.layer.cornerRadius = 4
        button.center = view.center
        button.frame.origin.y = view.bounds.height - 100 - button.frame.height
        if getAction() != nil {
            button.addTarget(self, action: getAction()!, for: .touchUpInside)
        }
        view.addSubview(button)
        
    }
    
    func getTitle() -> String {
        switch type {
            case .locationServices: return "Location Services"
            case .welcome: return "Welcome!"
            default: return ""
        }
    }
    
    func getDescription() -> String {
        switch type {
            case .locationServices: return "Lots of good information about location services!"
            case .welcome: return "This is the best app ever."
            default: return ""
        }
    }
    
    func getButtonText() -> String {
        switch type {
            case .locationServices: return "Enable"
            case .welcome: return "Let's Go!"
            default: return ""
        }
    }
    
    func getAction() -> Selector? {
        switch type {
            case .locationServices: return #selector(enableLocation)
            case .welcome: return #selector(dismissOnboarding)
            default: return nil
        }
    }
    
    func dismissOnboarding() {
        
        let rootVC = HomeViewController()
        let desiredViewController = UINavigationController(rootViewController: rootVC)
        // desiredViewController.getBusStops()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let snapshot: UIView = appDelegate.window!.snapshotView(afterScreenUpdates: true)!
        desiredViewController.view.addSubview(snapshot);
        
        appDelegate.window?.rootViewController = desiredViewController
        userDefaults.setValue(true, forKey: "onboardingShown")
        
        UIView.animate(withDuration: 0.5, animations: {
            snapshot.layer.opacity = 0
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
        
    }
    
    func enableLocation() {
        
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // if denied while onboarding...
        if status == .denied && !userDefaults.bool(forKey: "onboardingShown") {
            
            let title = "Location Services Disabled"
            let message = "The app won't be able to use your current location without permission. Tap Settings to turn on Location Services."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            let settings = UIAlertAction(title: "Settings", style: .default) { (_) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
            
            alertController.addAction(settings)
            present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
}

