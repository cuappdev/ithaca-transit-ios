//
//  TodayViewController.swift
//  Today Extension
//
//  Created by Yana Sang on 12/1/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import NotificationCenter
import SnapKit
import CoreLocation
import GoogleMaps
import GooglePlaces

 @objc(TodayViewController) class TodayViewController: UIViewController, NCWidgetProviding {

    var routesTable: UITableView = UITableView()
    var favorites: [String] = []
    var coordinates: [String] = []
    var routes: [Route] = []

    let group = DispatchGroup()
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        setUpLocation()

        GMSServices.provideAPIKey(Keys.googleMaps.value)
        GMSPlacesClient.provideAPIKey(Keys.googlePlaces.value)

        favorites = TodayExtensionManager.shared.retrieveFavoritesNames(for: Constants.UserDefaults.favorites)
        print("favorites retrieved: \(favorites.count)")
        for fav in favorites {
            print("favorite destination is: \(fav)")
        }

        group.enter()
        TodayExtensionManager.shared.retrieveFavoritesCoordinates(for: Constants.UserDefaults.favorites) { (coordsDict) in
            self.coordinates = TodayExtensionManager.shared.orderCoordinates(favorites: self.favorites, dictionary: coordsDict)
            self.group.leave()
        }

        group.notify(queue: .main) {
            print("# of coordinates retrieved: \(self.coordinates.count)")
            for coord in self.coordinates {
                print("favorite destination @: \(coord)")
            }

            // call multiroute

            self.setUpRoutesTableView()
            self.view.addSubview(self.routesTable)
            self.createConstraints()
        }
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view. (called to update the widget)

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        // update bus info?
        print("widgetPerformUpdate")

//        Network.getRoutes(startCoord: startCoord, endCoord: endCoord, endPlaceName: searchFrom.name, time: time, type: self.searchTimeType) { request in
//            let requestUrl = Network.getRequestUrl(startCoord: startCoord, endCoord: endCoord, destinationName: searchTo.name, time: time, type: self.searchTimeType)
//            self.processRequest(request: request, requestUrl: requestUrl, endPlace: searchTo)
//        }

//        if let currentLocation = currentLocation {
//            routes = Network.getMultiRoutes(startCoord: currentLocation, time: Date(), endCoords: coordinates, endPlaceNames: favorites) { request in
//
//            }
//        } else {
//            // could not determine current location
//        }

        // routesTable.reloadData()?

        completionHandler(NCUpdateResult.newData)
    }

    /// Called in response to the user tapping the “Show More” or “Show Less” buttons
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 110.0 * CGFloat(favorites.count)) : maxSize

        routesTable.reloadData()
    }

    func createConstraints() {
        routesTable.snp.makeConstraints {(make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(110.0*5)
        }
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        routesTable.reloadData()
//        createConstraints()
//    } WAS CAUSING ERROR DUE TO ROUTESTABLE NOT BEING ADDED TO SUPERVIEW YET

}

extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    private func setUpRoutesTableView() {
        routesTable.delegate = self
        routesTable.dataSource = self
        routesTable.allowsSelection = false
        routesTable.register(TodayExtensionCell.self, forCellReuseIdentifier: "todayExtensionCell")
        routesTable.register(NoFavoritesCell.self, forCellReuseIdentifier: "noFavoritesCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (extensionContext?.widgetActiveDisplayMode == .compact) ? 1 : (favorites.isEmpty) ? 1 : favorites.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (favorites.count != 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "todayExtensionCell", for: indexPath) as! TodayExtensionCell
            cell.setUpCell(destinationText: favorites[indexPath.row])
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "noFavoritesCell", for: indexPath) as! NoFavoritesCell
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // launch app via URL scheme --> route detail view
        // how to pass route as a parameter?
    }

}

extension TodayViewController: CLLocationManagerDelegate {
    private func setUpLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()

        if let location = locationManager.location {
            currentLocation = location.coordinate
        }
    }
}
