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
import SnapKit
import UIKit

class HomeMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    var mapView: GMSMapView!
    var bounds = GMSCoordinateBounds()
    var optionsCardVC: HomeOptionsCardViewController!
    
    let optionsCardInset = UIEdgeInsets.init(top: 92, left: 20, bottom: 0, right: 20)
    let minZoom: Float = 12
    let defaultZoom: Float = 15.5
    let maxZoom: Float = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()

        optionsCardVC = HomeOptionsCardViewController()
        add(optionsCardVC)
        optionsCardVC.delegate = self

        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
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

        let northEast = CLLocationCoordinate2D(latitude: Constants.Values.RouteMaxima.north, longitude: Constants.Values.RouteMaxima.east)
        let southWest = CLLocationCoordinate2D(latitude: Constants.Values.RouteMaxima.south, longitude: Constants.Values.RouteMaxima.west)
        let panBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        mapView.cameraTargetBounds = panBounds
        
        self.mapView = mapView
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupConstraints() {

        optionsCardVC.view.snp.makeConstraints { (make) in
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

extension HomeMapViewController: HomeOptionsCardDelegate {
    func updateSize() {
        optionsCardVC.view.snp.remakeConstraints { (make) in
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
