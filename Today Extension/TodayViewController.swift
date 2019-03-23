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
import TRON
import Alamofire
import SwiftyJSON

@objc(TodayViewController) class TodayViewController: UIViewController, NCWidgetProviding {

    var routesTable: UITableView = UITableView()
    var favorites: [String] = []
    var coordinates: [String] = []
    var routes: [Route?] = []

    var didFetchRoutes: Bool = false
    var numberOfFavorites: Int = 0

    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D?

    let cellHeight: CGFloat = 110.0

    override func viewDidLoad() {
        super.viewDidLoad()

        extensionContext?.widgetLargestAvailableDisplayMode = .compact

        setUpLocation()
        setUpRoutesTableView()
        view.addSubview(routesTable)
        createConstraints()

        favorites = TodayExtensionManager.shared.retrieveFavoritesNames()
        coordinates = TodayExtensionManager.shared.retrieveFavoritesCoordinates()
        numberOfFavorites = favorites.count

        searchForRoutes()
    }

    func searchForRoutes() {
        if numberOfFavorites > 0, let start = currentLocation {
            Network.getMultiRoutes(startCoord: start, time: Date(), endCoords: coordinates, endPlaceNames: favorites) { (request) in
                self.processRequest(request: request)
            }
        }
    }

    func processRequest(request: APIRequest<MultiRoutesRequest, Error>) {
        request.performCollectingTimeline { (response) in
            switch response.result {
            case .success(let routesResponse):
                self.routes = routesResponse.data
                self.rearrangeRoutes()
                self.didFetchRoutes = true
                self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
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
        print("Error Title: \(title)")
        print("Error Description: \(description)")
    }

    /// Called in response to the user tapping the “Show More” or “Show Less” buttons
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: cellHeight * CGFloat(numberOfFavorites)) : maxSize

        routesTable.reloadData()
    }

    func createConstraints() {
        routesTable.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(cellHeight*5)
        }
    }

    /// Re-orders routes so that walking-only routes are at the end of the list of routes. Modifies the list of favorites and coordinates coorespondingly.
    func rearrangeRoutes() {
        var nonNilRoutes = [Route?]()
        var nonNilFavorites = [String]()
        var nonNilCoordinates = [String]()

        var nilRoutes = [Route?]()
        var nilFavorites = [String]()
        var nilCoordinates = [String]()

        routes.enumerated().forEach { (index, route) in
            if route?.directions.first(where: { $0.type == .depart }) != nil {
                nonNilRoutes.append(route)
                nonNilFavorites.append(favorites[index])
                nonNilCoordinates.append(coordinates[index])
            } else {
                nilRoutes.append(route)
                nilFavorites.append(favorites[index])
                nilCoordinates.append(coordinates[index])
            }
        }

        favorites = nonNilFavorites + nilFavorites
        coordinates = nonNilCoordinates + nilCoordinates
        routes = nonNilRoutes + nilRoutes
    }
}

extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    private func setUpRoutesTableView() {
        routesTable.delegate = self
        routesTable.dataSource = self
        routesTable.register(TodayExtensionCell.self, forCellReuseIdentifier: Constants.TodayExtension.contentCellIdentifier)
        routesTable.register(TodayExtensionErrorCell.self, forCellReuseIdentifier: Constants.TodayExtension.errorCellIdentifier)
        routesTable.register(LoadingTableViewCell.self, forCellReuseIdentifier: Constants.TodayExtension.loadingCellIdentifier)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isCompact = extensionContext?.widgetActiveDisplayMode == .compact

        if (isCompact || favorites.isEmpty || routes.isEmpty || !didFetchRoutes) {
            // if: in compact mode, no favorites added, failed to load routes, or in loading state
            return 1
        } else {
            return numberOfFavorites
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (numberOfFavorites != 0) { // if number of favorites = 0
            if (routes.isEmpty) { // no routes yet
                if (didFetchRoutes) { // tried to get routes, but none retrieved
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TodayExtension.errorCellIdentifier, for: indexPath) as! TodayExtensionErrorCell
                    cell.mainLabel.text = Constants.TodayExtension.unableToLoad
                    cell.selectionStyle = .none
                    return cell
                } else { // still fetching routes
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TodayExtension.loadingCellIdentifier, for: indexPath) as! LoadingTableViewCell
                    cell.selectionStyle = .none
                    return cell
                }
            }
            // have routes!! 
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TodayExtension.contentCellIdentifier, for: indexPath) as! TodayExtensionCell
            routes[indexPath.row]?.formatDirections(start: Constants.General.currentLocation, end: favorites[indexPath.row])
            cell.configure(route: routes[indexPath.row], destination: favorites[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }

        // else: favorites = 0
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TodayExtension.errorCellIdentifier, for: indexPath) as! TodayExtensionErrorCell
        cell.boldLabel.text = Constants.TodayExtension.addFavorite
        cell.mainLabel.text = Constants.TodayExtension.showTrips
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var stringURL: String = "ithaca-transit://"

        if numberOfFavorites != 0 {
            let latLong = coordinates[indexPath.row].components(separatedBy: ",")
            let latitude = latLong[0]
            let longitude = latLong[1]
            let destination = favorites[indexPath.row]

            stringURL += "getRoutes?lat=\(latitude)&long=\(longitude)&stopName=\(destination)"
        }

        if
            let url = stringURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let convertedURL = URL(string: url) {
            extensionContext?.open(convertedURL, completionHandler: nil)
        }

    }

}

extension TodayViewController: CLLocationManagerDelegate {

    private func setUpLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return
        }

        if currentLocation == nil {
            currentLocation = location.coordinate
            searchForRoutes()
        }
    }
}
