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
    case locationServices, welcome, favorites
}

protocol OnboardingDelegate {
    func moveToNextViewController(vc: ActionOnboardViewController)
}

class ActionOnboardViewController: UIViewController, CLLocationManagerDelegate {
    
    var type: OnboardType!
    var locationManager = CLLocationManager()
    var onboardingDelegate: OnboardingDelegate!

    let button = UIButton()
    let secondButton = UIButton()
    
    // working on DELEGATION
    
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
        
        view.backgroundColor = .white
        
        createView()
        
    }
    
    func createView() {
        
        let title = UILabel()
        let description = UITextView()
        let image = UIImageView()
        
        view.addSubview(button)
        view.addSubview(title)
        view.addSubview(description)
        view.addSubview(image)
        view.addSubview(secondButton)
        
        image.backgroundColor = .clear
        image.snp.makeConstraints { (make) in
            make.width.equalTo(311)
            make.height.equalTo(325.5)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(32)
        }
        
        title.font = UIFont(name: FontNames.SanFrancisco.Bold, size: 28)
        title.textColor = UIColor.primaryTextColor
        title.text = getTitle()
        title.center = view.center
        title.textAlignment = .center
        title.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-244)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        
        description.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14)
        description.textColor = UIColor.mediumGrayColor
        description.text = getDescription()
        description.textAlignment = .center
        description.snp.makeConstraints { (make) in
            make.top.equalTo(title.snp.bottom).offset(12)
            make.width.equalTo(311.5)
            make.height.equalTo(80)
            make.centerX.equalToSuperview()
        }
        description.isEditable = false
        
        button.setTitle(getButtonText(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Medium, size: 16)!
        button.backgroundColor = UIColor.tcatBlueColor
        button.layer.cornerRadius = 4
        self.button.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        setButtonConstraints()

        secondButton.setTitleColor(UIColor.tcatBlueColor, for: .normal)
        secondButton.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Medium, size: 16)
        secondButton.backgroundColor = .clear
        secondButton.snp.makeConstraints { (make) in
            make.top.equalTo(button.snp.bottom).offset(12)
            make.width.equalTo(100)
            make.centerX.equalToSuperview()
        }
        secondButton.addTarget(self, action: #selector(dismissOnboarding), for: .touchUpInside)
        
        if getAction() != nil {
            button.addTarget(self, action: getAction()!, for: .touchUpInside)
        }
        
    }
    
    func getTitle() -> String {
        switch type! {
        case .locationServices: return "Location Services"
        case .welcome: return "Welcome!"
        case .favorites: return "Favorites"
        }
    }
    
    func setButtonConstraints() {
        switch type! {
        case .locationServices, .favorites:
            self.button.snp.makeConstraints { (make) in
                make.width.equalTo(224)
            }
            secondButton.isHidden = false
            let title = type == .locationServices ? "Don't Allow" : "Not Now"
            secondButton.setTitle(title, for: .normal)
        case .welcome:
            self.button.snp.makeConstraints { (make) in
                make.width.equalTo(128)
            }
            secondButton.isHidden = true
        }
    }
    
    func getDescription() -> String {
        switch type! {
        case .locationServices:
            return "Please enable location services to allow the app to use your current location."
        case .welcome:
            return "Welcome to Ithaca’s first end-to-end transit navigation service. Made by Cornell App Development."
        case .favorites:
            return "Add some favorites so you can ride the magical school bus faster!"
        }
    }
    
    func getButtonText() -> String {
        switch type! {
        case .locationServices:
            return "Enable Location Services"
        case .welcome:
            return "Get started"
        case .favorites:
            return "Add Favorites"
        }
    }
    
    func getAction() -> Selector? {
        switch type! {
        case .locationServices: return #selector(enableLocation)
        case .welcome: return #selector(moveToNextViewController)
        case .favorites: return #selector(presentFavoritesTVC)
        }
    }
    
    @objc func moveToNextViewController() {
        onboardingDelegate.moveToNextViewController(vc: self)
    }

    @objc func presentFavoritesTVC() {
        let favoritesTVC = FavoritesTableViewController()
        favoritesTVC.fromOnboarding = true
        let navController = UINavigationController(rootViewController: favoritesTVC)
        present(navController, animated: true, completion: nil)

    }
    
    @objc func dismissOnboarding() {
        
        let rootVC = HomeViewController()
        let desiredViewController = UINavigationController(rootViewController: rootVC)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let snapshot: UIView = appDelegate.window!.snapshotView(afterScreenUpdates: true)!
        desiredViewController.view.addSubview(snapshot)
        
        appDelegate.window?.rootViewController = desiredViewController
        userDefaults.setValue(true, forKey: "onboardingShown")
        
        UIView.animate(withDuration: 0.5, animations: {
            snapshot.layer.opacity = 0
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
        
    }
    
    @objc func enableLocation() {
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse && type == .locationServices {
            dismissOnboarding()
            //moveToNextViewController()
        }

        // if denied while onboarding...
        if status == .denied && !userDefaults.bool(forKey: "onboardingShown") && type == .locationServices {
            
            let title = "Location Services Disabled"
            let message = "The app won't be able to use your current location without permission. Tap Settings to turn on Location Services."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                self.dismissOnboarding()
            }
            let settings = UIAlertAction(title: "Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            }

            alertController.addAction(cancel)
            alertController.addAction(settings)
            present(alertController, animated: true, completion: nil)
            
        }        
    }
}
