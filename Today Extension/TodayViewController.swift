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
import TRON
import Alamofire
import SwiftyJSON

 @objc(TodayViewController) class TodayViewController: UIViewController, NCWidgetProviding {

    var routesTable: UITableView = UITableView()
    var favorites: [String] = []
    var coordinates: [String] = []
    var routes: [Route?] = []

    let group = DispatchGroup()
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        setUpLocation()
        setUpRoutesTableView()

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

//            self.setUpRoutesTableView()
//            self.view.addSubview(self.routesTable)
//            self.createConstraints()
            // call multiroute
            self.searchForRoutes()
        }

        view.addSubview(routesTable)
        createConstraints()
    }

    func searchForRoutes() {
        if let currentLocation = currentLocation {
            Network.getMultiRoutes(startCoord: currentLocation, time: Date(), endCoords: coordinates, endPlaceNames: favorites) { (request) in
                self.processRequest(request: request)
            }
        } else {
            // could not determine current location
        }
    }

    func processRequest(request: APIRequest<MultiRoutesRequest, Error>) {
        request.performCollectingTimeline { (response) in
            switch response.result {
            case .success(let routesResponse):
//                for each in routesResponse.data {
//                    each?.formatDirections(start: Constants.General.currentLocation, end: self.searchTo?.name)
//                }
                self.routes = routesResponse.data
                self.routesTable.reloadData()
            case .failure(let networkError):
                if let error = networkError as? APIError<Error> {
                    self.processRequestError(error: error)
                }
            }
        }
    }

    func processRequestError(error: APIError<Error>) {
        let title = "Network Failure: \((error.error as NSError?)?.domain ?? "No Domain")"
        let description = (error.localizedDescription) + ", " + ((error.error as NSError?)?.description ?? "n/a")

        routes = []
        print(title)
        print(description)
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view. (called to update the widget)

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        // update bus info?
        print("widgetPerformUpdate")

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
        routesTable.register(NoRoutesCell.self, forCellReuseIdentifier: "noRoutesCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isCompact = extensionContext?.widgetActiveDisplayMode == .compact

        if (isCompact || favorites.isEmpty) {
            return 1
        } else if (routes.isEmpty) {
            return 1
        } else {
            return favorites.count
        }
//        return (extensionContext?.widgetActiveDisplayMode == .compact) ? 1 : (favorites.isEmpty) ? 1 : favorites.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (favorites.count != 0) {
            if (routes.isEmpty) { // no routes retrieved
                let cell = tableView.dequeueReusableCell(withIdentifier: "noRoutesCell", for: indexPath) as! NoRoutesCell
                return cell
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "todayExtensionCell", for: indexPath) as! TodayExtensionCell
            routes[indexPath.row]?.formatDirections(start: Constants.General.currentLocation, end: favorites[indexPath.row])
            cell.setUpCell(route: routes[indexPath.row])
            return cell
        }

        // else: favorites = 0
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
