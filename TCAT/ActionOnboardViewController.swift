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
    
    let button = UIButton()
    
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
        
        self.view.backgroundColor = .white
        
        createView()
        
    }
    
    func createView() {
        
        let spacing: CGFloat = 16
        let edgeInset: CGFloat = 2
        
        let title = UILabel()
        let description = UITextView()
        
        view.addSubview(button)
        view.addSubview(title)
        view.addSubview(description)
        
        title.font = UIFont(name: FontNames.SanFrancisco.Medium, size: 28)
        title.text = getTitle()
        title.center = view.center
        title.textAlignment = .center
        title.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        
        description.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14)
        description.text = getDescription()
        description.textAlignment = .center
        description.snp.makeConstraints { (make) in
            make.top.equalTo(title.snp.bottom).offset(spacing)
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(80)
            make.centerX.equalToSuperview()
        }
        description.isEditable = false
        
        button.setTitle(getButtonText(), for: .normal)
        button.setTitleColor(.buttonColor, for: .normal)
        button.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14)!
        button.backgroundColor = .white
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.buttonColor.cgColor
        self.button.snp.makeConstraints { (make) in
            make.top.equalTo(description.snp.bottom).offset(50)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
        }
        setButtonConstraints()
        
        if getAction() != nil {
            button.addTarget(self, action: getAction()!, for: .touchUpInside)
        }
        
    }
    
    func getTitle() -> String {
        switch type {
        case .locationServices: return "Location Services"
        case .welcome: return "Welcome!"
        default: return ""
        }
    }
    
    func setButtonConstraints() {
        switch type {
        case .locationServices:
            self.button.snp.makeConstraints { (make) in
                make.width.equalTo(200)
            }
            return
        case .welcome:
            self.button.snp.makeConstraints { (make) in
                make.width.equalTo(100)
            }
            return
        default: return
        }
    }
    
    func getDescription() -> String {
        switch type {
        case .locationServices:
            return "We need location services to serve you. "
        case .welcome:
            return "This is the magic school bus. If you need to get to somewhere in Ithaca, then use this."
        default: return ""
        }
    }
    
    func getButtonText() -> String {
        switch type {
        case .locationServices:
            return "Enable Location Services"
        case .welcome:
            return "Get started"
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
        
        if status == .authorizedWhenInUse {
            dismissOnboarding()
        }
        
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
