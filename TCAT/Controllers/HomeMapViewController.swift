//
//  HomeMapViewController.swift
//  TCAT
//
//  Created by Omar Rasheed on 3/23/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import CoreLocation
import GoogleMaps
import MapKit
import NotificationBannerSwift
import SnapKit
import UIKit

protocol HomeMapViewDelegate {
    func searchCancelButtonClicked()
    func updatePlaces()
    func networkDown()
    func networkUp()
}

class HomeMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    var delegate: HomeMapViewDelegate?
    var mapView: GMSMapView!
    var bounds = GMSCoordinateBounds()
    var isKeyboardVisible = false
    var isNetworkDown = false {
        didSet {
            if isNetworkDown {
                delegate?.networkDown()
            } else {
                delegate?.networkUp()
            }
        }
    }
    var optionsCardVC: HomeOptionsCardViewController!
    var optionsCard: UIView!
    
    let optionsCardInset = UIEdgeInsets.init(top: 92, left: 20, bottom: 0, right: 20)
    let minZoom: Float = 12
    let defaultZoom: Float = 15.5
    let maxZoom: Float = 25
    
    let reachability = Reachability(hostname: Network.ipAddress)
    
    var banner: StatusBarNotificationBanner? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionsCardVC = HomeOptionsCardViewController()
        add(optionsCardVC)
        delegate = optionsCardVC
        optionsCardVC.delegate = self
        
        setupOptionsCard()
        
        updatePlaces()
        
        // Add Notification Observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupConstraints()
    }
    
    override func loadView() {
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        updatePlaces()
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(_:)),
                                               name: .reachabilityChanged,
                                               object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("HomeVC viewDidLayoutSubviews: Could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(_ notification: Notification) {
        guard let reachability = notification.object as? Reachability else {
            return
        }
        
        // Dismiss current banner or loading indicator, if any
        banner?.dismiss()
        banner = nil
        
        switch reachability.connection {
        case .none:
            banner = StatusBarNotificationBanner(title: Constants.Banner.noInternetConnection, style: .danger)
            banner?.autoDismiss = false
            banner?.show(queuePosition: .front, on: navigationController)
            self.isNetworkDown = true
        case .cellular, .wifi:
            self.isNetworkDown = false
        }
    }
    
    func setupMapView() {
        // Set mapView with settings
        let camera = GMSCameraPosition.camera(withLatitude: 42.446179, longitude: -76.485070, zoom: defaultZoom)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.paddingAdjustmentBehavior = .never // handled by code
        mapView.setMinZoom(minZoom, maxZoom: maxZoom)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.tiltGestures = false
        mapView.settings.indoorPicker = false
        mapView.isBuildingsEnabled = false
        mapView.isIndoorEnabled = false
        
        // Pre-iOS 11 padding. See viewDidLoad for iOS 11 version
        let top = (navigationController?.navigationBar.frame.height ?? 44) + UIApplication.shared.statusBarFrame.height
        mapView.padding = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        
        let northEast = CLLocationCoordinate2D(latitude: Constants.Values.RouteMaxima.north, longitude: Constants.Values.RouteMaxima.east)
        let southWest = CLLocationCoordinate2D(latitude: Constants.Values.RouteMaxima.south, longitude: Constants.Values.RouteMaxima.west)
        let panBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        mapView.cameraTargetBounds = panBounds
        
        self.mapView = mapView
        view = mapView
    }
    
    
    func setupOptionsCard() {
        optionsCard = optionsCardVC.view
        view.addSubview(optionsCard)
    }
    
    func setupConstraints() {
        
        optionsCard.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(optionsCardInset)
            make.leading.equalToSuperview().inset(20)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaInsets.top + 40)
            } else {
                make.top.equalToSuperview().offset(view.layoutMargins.top + 20)
            }
            make.height.equalTo(optionsCardVC.calculateCardHeight())
        }
    }

    /* Keyboard Functions */
    @objc func keyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
        delegate?.searchCancelButtonClicked()
    }
    
    func updatePlaces() {
        delegate?.updatePlaces()
        if !isNetworkDown {
            delegate?.networkUp()
        } else {
            delegate?.networkDown()
        }
        
    }
}

extension HomeMapViewController: HomeOptionsCardDelegate {
    func updateSize() {
        optionsCard.snp.remakeConstraints { (make) in
            make.trailing.equalToSuperview().inset(optionsCardInset)
            make.leading.equalToSuperview().inset(20)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaInsets.top + 40)
            } else {
                make.top.equalToSuperview().offset(view.layoutMargins.top + 20)
            }
            make.height.equalTo(optionsCardVC.calculateCardHeight())
        }
    }
}
