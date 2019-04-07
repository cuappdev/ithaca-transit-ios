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

class HomeMapViewController: UIViewController {

    var mapView: GMSMapView!
    var bounds = GMSCoordinateBounds()
    var optionsCardVC: HomeOptionsCardViewController!
    
    static let optionsCardInset = UIEdgeInsets.init(top: UIScreen.main.bounds.height/10, left: 20, bottom: 0, right: 20)
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
            make.leading.top.trailing.equalToSuperview().inset(HomeMapViewController.optionsCardInset)
            make.height.equalTo(optionsCardVC.calculateCardHeight())
        }
    }
}

extension HomeMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        optionsCardVC.searchBar.endEditing(true)
//        optionsCardVC.searchBarCancelButtonClicked(optionsCardVC.searchBar) // If we want to remove their search
    }
}

extension HomeMapViewController: HomeOptionsCardDelegate {

    func updateSize() {
        let newCardHeight = optionsCardVC.calculateCardHeight()
        if newCardHeight > optionsCardVC.view.frame.height {
            UIView.animate(withDuration: 0.2) {
                self.optionsCardVC.view.snp.remakeConstraints { (make) in
                    make.leading.top.trailing.equalToSuperview().inset(HomeMapViewController.optionsCardInset)
                    make.height.equalTo(newCardHeight)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
}
