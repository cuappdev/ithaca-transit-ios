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
    case locationServices, welcome, favorites, tracking, destination
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

        secondButton.setTitleColor(UIColor.tcatBlueColor, for: .normal)
        secondButton.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Medium, size: 16)
        secondButton.backgroundColor = .clear
        secondButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            } else {
                make.bottom.equalToSuperview().offset(-16)
            }
            make.width.equalTo(100)
            make.centerX.equalToSuperview()
            make.height.equalTo(21)
        }
        secondButton.addTarget(self, action: #selector(dismissOnboarding), for: .touchUpInside)

        button.setTitle(getButtonText(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Medium, size: 16)!
        button.backgroundColor = UIColor.tcatBlueColor
        button.layer.cornerRadius = 4
        self.button.snp.makeConstraints { (make) in
            make.bottom.equalTo(secondButton.snp.top).offset(-12)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }

        description.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 16)
        description.textColor = UIColor.mediumGrayColor
        description.text = getDescription()
        description.textAlignment = .center
        description.isEditable = false
        description.isScrollEnabled = false
        description.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.bottom.lessThanOrEqualTo(button.snp.top).offset(-8)
            make.centerX.equalToSuperview()
        }

        title.font = UIFont(name: FontNames.SanFrancisco.Bold, size: 26)
        title.textColor = UIColor.primaryTextColor
        title.text = getTitle()
        title.center = view.center
        title.textAlignment = .center
        title.adjustsFontSizeToFitWidth = true
        title.snp.makeConstraints { (make) in
            make.bottom.equalTo(description.snp.top).offset(-12)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }

        image.backgroundColor = .clear
        image.image = getImage()
        image.contentMode = .scaleAspectFit
        image.snp.makeConstraints { (make) in
            make.width.equalTo(image.snp.height)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.top.equalToSuperview().offset(32)
            make.bottom.equalTo(title.snp.top).offset(-32)

        }
        
        setButtonConstraints()
        
        if getAction() != nil {
            button.addTarget(self, action: getAction()!, for: .touchUpInside)
        }
        
    }
    
    func getTitle() -> String {
        switch type! {
        case .welcome: return "Never miss the bus again."
        case .tracking: return "Track buses in real time."
        case .destination: return "Search any destination."
        case .locationServices: return "Simplify your transit."
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
        case .welcome, .tracking, .destination:
            self.button.snp.makeConstraints { (make) in
                make.width.equalTo(128)
            }
            secondButton.isHidden = true
        }
    }
    
    func getDescription() -> String {
        switch type! {
        case .welcome:
            return "Welcome to Ithaca’s first end-to-end navigation service for the TCAT, made by Cornell AppDev."
        case .tracking:
            return "No more uncertainty. Know exactly where your bus is, updated every 30 seconds."
        case .destination:
            return "From Teagle Hall to Taughannock Falls, search any location and get there fast."
        case .favorites:
            return "Add some favorites so you can ride the magical school bus faster!"
        case .locationServices:
            return "Enable location services to allow the app to use your current location. It’s really handy."
        }
    }
    
    func getButtonText() -> String {
        switch type! {
        case .welcome:
            return "Get Started"
        case .tracking, .destination:
            return "Continue"
        case .favorites:
            return "Add Favorites"
        case .locationServices:
            return "Enable Location Services"
        }
    }

    func getImage() -> UIImage {
        switch type! {
        case .welcome: return #imageLiteral(resourceName: "welcome")
        case .tracking: return #imageLiteral(resourceName: "tracking")
        case .destination: return #imageLiteral(resourceName: "destination")
        case .favorites: return #imageLiteral(resourceName: "welcome")
        case .locationServices: return #imageLiteral(resourceName: "locationServices")
        }
    }
    
    func getAction() -> Selector? {
        switch type! {
        case .welcome, .tracking, .destination: return #selector(moveToNextViewController)
        case .favorites: return #selector(presentFavoritesTVC)
        case .locationServices: return #selector(enableLocation)
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
