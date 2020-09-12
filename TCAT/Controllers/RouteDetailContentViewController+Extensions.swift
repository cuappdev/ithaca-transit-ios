//
//  RouteDetailContentViewController+Extensions.swift
//  TCAT
//
//  Created by Omar Rasheed on 8/29/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import CoreLocation
import GoogleMaps
import MapKit
import UIKit

// MARK: - View Life Cycle
extension RouteDetailContentViewController {

    override func viewSafeAreaInsetsDidChange() {
        let top = view.safeAreaInsets.top
        let bottom = view.safeAreaInsets.bottom + (drawerDisplayController?.summaryView.frame.height ?? 92)
        mapView.padding = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Live Tracking Network Timer
        liveTrackingNetworkTimer?.invalidate()
        if directions.contains(where: { $0.type != .walk }) {
            liveTrackingNetworkTimer = Timer.scheduledTimer(
                timeInterval: liveTrackingNetworkRefreshRate,
                target: self,
                selector: #selector(getBusLocations),
                userInfo: nil,
                repeats: true
            )
            liveTrackingNetworkTimer?.fire()
        }
        centerMapOnOverview(drawerPreviewing: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        liveTrackingNetworkTimer?.invalidate()
        hideBanner()
    }

    override func loadView() {
        // Set mapView with settings
        let camera = GMSCameraPosition.camera(
            withLatitude: Constants.Map.startingLat,
            longitude: Constants.Map.startingLong,
            zoom: Constants.Map.defaultZoom
        )
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.paddingAdjustmentBehavior = .never // handled by code
        mapView.setMinZoom(Constants.Map.minZoom, maxZoom: Constants.Map.maxZoom)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.tiltGestures = false
        mapView.settings.indoorPicker = false
        mapView.isBuildingsEnabled = false
        mapView.isIndoorEnabled = false

        // Pre-iOS 11 padding. See viewDidLoad for iOS 11 version
        let top = (navigationController?.navigationBar.frame.height ?? 44) + UIApplication.shared.statusBarFrame.height
        let bottom = drawerDisplayController?.summaryView.frame.height ?? 0
        mapView.padding = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)

        let northEast = CLLocationCoordinate2D(latitude: Constants.Values.RouteMaxima.north, longitude: Constants.Values.RouteMaxima.east)
        let southWest = CLLocationCoordinate2D(latitude: Constants.Values.RouteMaxima.south, longitude: Constants.Values.RouteMaxima.west)
        let panBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        mapView.cameraTargetBounds = panBounds

        self.mapView = mapView
        view = mapView
    }
}

// MARK: - Location Manager Functions
extension RouteDetailContentViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newCoord = locations.last?.coordinate {
            bounds = bounds.includingCoordinate(newCoord)
            currentLocation = newCoord
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        printClass(context: "CLLocationManager didFailWithError", message: error.localizedDescription)
    }
}

// MARK: - Google Map View Delegate Functions
extension RouteDetailContentViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let coordinates = getUserData(for: marker, key: Constants.BusUserData.actualCoordinates) as? CLLocationCoordinate2D
            else { return true }
        let update = GMSCameraUpdate.setTarget(coordinates)
        mapView.animate(with: update)

        return true
    }

    func updateUserData(for marker: GMSMarker, with values: [String: Any]) {
        guard var userData = marker.userData as? [String: Any] else {
            marker.userData = values
            return
        }
        values.forEach { (key, value) in
            userData[key] = value
        }
        marker.userData = userData
    }

    func getUserData(for marker: GMSMarker, key: String) -> Any? {
        guard let userData = marker.userData as? [String: Any] else { return nil }
        return userData[key]
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        buses.forEach { bus in
            let bearingView = UIImageView(image: #imageLiteral(resourceName: "indicator"))
            bearingView.frame.size = CGSize(width: bearingView.frame.width / 2, height: bearingView.frame.height / 2)
            bearingView.tag = increaseTapTargetTag

            if let existingIndicator = busIndicators.first(where: {
                let markerID = getUserData(for: $0, key: Constants.BusUserData.vehicleID) as? Int
                let busID = getUserData(for: bus, key: Constants.BusUserData.vehicleID) as? Int
                return markerID == busID
            }) { // Update Indicator
                if let placement = calculatePlacement(position: bus.position, view: bearingView) {
                    // Uncomment to avoid animation
                    // existingIndicator.map = nil 
                    existingIndicator.position = placement
                    existingIndicator.rotation = calculateBearing(from: placement, to: bus.position)

                    updateUserData(for: existingIndicator, with: [
                        Constants.BusUserData.actualCoordinates: bus.position,
                        Constants.BusUserData.indicatorCoordinates: placement
                        ])

                    existingIndicator.appearAnimation = .none
                    // Uncomment to avoid animation
                    // existingIndicator.map = mapView
                } else {
                    existingIndicator.map = nil
                    busIndicators.remove(at: busIndicators.firstIndex(of: existingIndicator)!)
                }
                return
            }

            if let placement = calculatePlacement(position: bus.position, view: bearingView) {
                let indicator = GMSMarker(position: placement)
                indicator.appearAnimation = .pop
                indicator.rotation = calculateBearing(from: placement, to: bus.position)
                indicator.iconView = bearingView
                setIndex(of: indicator, with: .bussing)

                updateUserData(
                    for: indicator,
                    with: [
                    Constants.BusUserData.actualCoordinates: bus.position,
                    Constants.BusUserData.indicatorCoordinates: placement,
                    Constants.BusUserData.vehicleID: getUserData(for: bus, key: Constants.BusUserData.vehicleID) as? Int ?? -1
                    ]
                )

                indicator.map = mapView
                busIndicators.append(indicator)
            }
        }
    }
}

// MARK: - Debug
extension RouteDetailContentViewController {

    /// Create fake bus for debugging and testing bus indicators
    private func createDebugBusIcon() {
        let bus = BusLocation(
            dataType: .validData,
            destination: "",
            deviation: 0,
            delay: 0,
            direction: "",
            displayStatus: "",
            gpsStatus: 0,
            heading: 0,
            lastStop: "",
            lastUpdated: Date(),
            latitude: 42.4491411,
            longitude: -76.4836815,
            name: "16",
            opStatus: "",
            routeID: 10,
            runID: 0,
            speed: 0,
            tripID: 0,
            vehicleID: 0
        )
        let coords = CLLocationCoordinate2D(latitude: 42.4491411, longitude: -76.4836815)
        let marker = GMSMarker(position: coords)
        marker.iconView = bus.iconView
        marker.appearAnimation = .pop
        setIndex(of: marker, with: .bussing)
        updateUserData(
            for: marker,
            with: [
            Constants.BusUserData.actualCoordinates: coords,
            Constants.BusUserData.vehicleID: 123456789
            ]
        )
        marker.map = mapView
        buses.append(marker)
    }
}
