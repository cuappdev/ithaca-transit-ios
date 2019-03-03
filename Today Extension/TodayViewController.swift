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

    var didFetchRoutes: Bool = false

    let group = DispatchGroup()
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")

        extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        setUpLocation()
        setUpRoutesTableView()

        GMSServices.provideAPIKey(Keys.googleMaps.value)
        GMSPlacesClient.provideAPIKey(Keys.googlePlaces.value)

        favorites = TodayExtensionManager.shared.retrieveFavoritesNames(for: Constants.UserDefaults.favorites)
        print("retrieved favorites")

        group.enter()
        TodayExtensionManager.shared.retrieveFavoritesCoordinates(for: Constants.UserDefaults.favorites) { (coordsDict) in
            self.coordinates = TodayExtensionManager.shared.orderCoordinates(favorites: self.favorites, dictionary: coordsDict)
            self.group.leave()
            print("retrieved coordinates")
        }

        group.notify(queue: .main) {
            print("searching for routes")
            self.searchForRoutes()
        }

        view.addSubview(routesTable)
        createConstraints()
    }

    func searchForRoutes() {
        if let currentLocation = currentLocation {
            Network.getMultiRoutes(startCoord: currentLocation, time: Date(), endCoords: coordinates, endPlaceNames: favorites) { (request) in
                print("fetching new routes...")
                self.processRequest(request: request)
            }
        } else {
            print("if let currentLocation failed")
        }
    }

    func processRequest(request: APIRequest<MultiRoutesRequest, Error>) {
        request.performCollectingTimeline { (response) in
            switch response.result {
            case .success(let routesResponse):
                self.routes = routesResponse.data
                self.didFetchRoutes = true
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
        
//        completionHandler
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
        // routesTable.allowsSelection = false
        routesTable.register(TodayExtensionCell.self, forCellReuseIdentifier: "todayExtensionCell")
        routesTable.register(NoFavoritesCell.self, forCellReuseIdentifier: "noFavoritesCell")
        routesTable.register(NoRoutesCell.self, forCellReuseIdentifier: "noRoutesCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isCompact = extensionContext?.widgetActiveDisplayMode == .compact

        if (isCompact || favorites.isEmpty || routes.isEmpty) {
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "noRoutesCell", for: indexPath) as! NoRoutesCell
                if (didFetchRoutes) { // no routes retrieved
                    cell.noRoutesLabel.text = "Unable to Load Routes"
                    return cell
                } else { // still fetching routes
                    cell.noRoutesLabel.text = ""
                    return cell
                }
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "todayExtensionCell", for: indexPath) as! TodayExtensionCell
            routes[indexPath.row]?.formatDirections(start: Constants.General.currentLocation, end: favorites[indexPath.row])
            cell.setUpCell(route: routes[indexPath.row], destination: favorites[indexPath.row])
            return cell
        }

        // else: favorites = 0
        let cell = tableView.dequeueReusableCell(withIdentifier: "noFavoritesCell", for: indexPath) as! NoFavoritesCell
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // launch app via URL scheme --> route OPTIONS view (to be changed to route detail view later on
        
        let latLong = coordinates[indexPath.row].components(separatedBy: ",")
        let latitude = latLong[0]
        let longitude = latLong[1]
        let destination = favorites[indexPath.row]
        
        let stringURL = "ithaca-transit://getRoutes?lat=\(latitude)&long=\(longitude)&stopName=\(destination)"
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
        locationManager.startUpdatingLocation()

        if let location = locationManager.location {
            currentLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location.coordinate
        }
    } 
}
