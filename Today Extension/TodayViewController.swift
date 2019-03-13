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

    let group = DispatchGroup()
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        extensionContext?.widgetLargestAvailableDisplayMode = .compact

        setUpLocation()
        setUpRoutesTableView()
        view.addSubview(routesTable)
        createConstraints()

        favorites = TodayExtensionManager.shared.retrieveFavoritesNames()
        print("retrieved \(favorites.count) favorite(s)")
        coordinates = TodayExtensionManager.shared.retrieveFavoritesCoordinates()
        print("retrieved \(coordinates.count) coordinate(s)")

        searchForRoutes()
    }

    func searchForRoutes() {
        if favorites.count > 0 {
            if let start = currentLocation {
                Network.getMultiRoutes(startCoord: start, time: Date(), endCoords: coordinates, endPlaceNames: favorites) { (request) in
                    print("fetching new routes...")
                    self.processRequest(request: request)
                }
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
                print("reloaded table view")
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

        print("widgetPerformUpdate")

        //if let start = currentLocation {
            //searchForRoutes()
        //}

//        completionHandler(NCUpdate.NewData)
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

    func rearrangeRoutes() {
        var nonNilRoutes = [Route?]()
        var nonNilFavorites = [String]()
        var nonNilCoordinates = [String]()

        var nilRoutes = [Route?]()
        var nilFavorites = [String]()
        var nilCoordinates = [String]()

        for i in 0..<routes.count {

            if (routes[i]?.directions.filter { $0.type == .depart })?.first != nil {
                nonNilRoutes.append(routes[i])
                nonNilFavorites.append(favorites[i])
                nonNilCoordinates.append(coordinates[i])
            } else {
                nilRoutes.append(routes[i])
                nilFavorites.append(favorites[i])
                nilCoordinates.append(coordinates[i])
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
            return 1
        } else {
            return favorites.count
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (favorites.count != 0) {
            if (routes.isEmpty) {
                if (didFetchRoutes) { // no routes retrieved
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TodayExtension.errorCellIdentifier, for: indexPath) as! TodayExtensionErrorCell
                    cell.mainLabel.text = "Unable to Load Routes"
                    cell.selectionStyle = .none
                    return cell
                } else { // still fetching routes
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TodayExtension.loadingCellIdentifier, for: indexPath) as! LoadingTableViewCell
                    cell.selectionStyle = .none
                    return cell
                }
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TodayExtension.contentCellIdentifier , for: indexPath) as! TodayExtensionCell
            routes[indexPath.row]?.formatDirections(start: Constants.General.currentLocation, end: favorites[indexPath.row])
            cell.setUpCell(route: routes[indexPath.row], destination: favorites[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }

        // else: favorites = 0
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TodayExtension.errorCellIdentifier, for: indexPath) as! TodayExtensionErrorCell
        cell.boldLabel.text = "Add a favorite "
        cell.mainLabel.text = "to show favorite trips here."
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // launch app via URL scheme --> route OPTIONS view (to be changed to route detail view later on

        var stringURL : String
        
        if favorites.count == 0 {
            stringURL = "ithaca-transit://"
        } else {
            let latLong = coordinates[indexPath.row].components(separatedBy: ",")
            let latitude = latLong[0]
            let longitude = latLong[1]
            let destination = favorites[indexPath.row]

            stringURL = "ithaca-transit://getRoutes?lat=\(latitude)&long=\(longitude)&stopName=\(destination)"
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
