//
//  RouteOptionsViewController.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import Crashlytics
import DZNEmptyDataSet
import FutureNova
import Intents
import NotificationBannerSwift
import Pulley
import SwiftyJSON
import UIKit

enum SearchBarType: String {
    case from, to
}

struct BannerInfo {
    let title: String
    let style: BannerStyle
}

enum RequestAction {
    case hideBanner
    case showAlert(title: String, message: String, actionTitle: String)
    case showError(bannerInfo: BannerInfo, payload: GetRoutesErrorPayload)
}

class RouteOptionsViewController: UIViewController {
    let datePickerOverlay = UIView()
    var datePickerView: DatePickerView!
    let routeResults = UITableView(frame: .zero, style: .grouped)
    let routeSelection = RouteSelectionView()
    var searchBarView = SearchBarView()

    var cellUserInteraction = true
    var currentLocation: CLLocationCoordinate2D?
    var lastRouteRefreshDate = Date()
    var locationManager: CLLocationManager!
    var routes: [[Route]] = []
    var searchFrom: Place?
    var searchTime: Date?
    var searchTimeType: SearchType = .leaveNow
    var searchTo: Place!
    var searchType: SearchBarType = .to
    var showRouteSearchingLoader: Bool = false
    var trips: [Trip] = []

    // Variable to remember back button when hiding
    private var backButton: UIBarButtonItem?
    var refreshControl: UIRefreshControl!

    private let estimatedRowHeight: CGFloat = 115
    private let mediumTapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let networking: Networking = URLSession.shared.request
    private let reachability: Reachability? = Reachability(hostname: Endpoint.config.host ?? "")
    private let routeResultsTitle: String = Constants.Titles.routeResults
    
    // Timer to retrieve route delays and update route cells
    private var routeTimer: Timer?
    private var updateTimer: Timer?
    
    // Dictionary to map route id to delay
    var delayDictionary: [String: DelayState] = [:]
    
    // Dictionary to map tripId to route
    var tripDictionary: [String: Route] = [:]
    
    /// Returns routes from each section in order
    private var allRoutes: [Route] {
        return routes.flatMap { $0 }
    }

    private var banner: StatusBarNotificationBanner? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    init(searchTo: Place) {
        super.init(nibName: nil, bundle: nil)
        self.searchTo = searchTo
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.backgroundWash

        edgesForExtendedLayout = []

        title = Constants.Titles.routeOptions

        setupRouteSelection(destination: searchTo)
        setupSearchBar()
        setupDatePicker()
        setupRouteResultsTableView()

        setupRouteSelection(destination: searchTo)
        setupLocationManager()

        // assume user wants to find routes that leave at current time and set datepicker accordingly
        searchTime = Date()
        if let searchTime = searchTime {
            routeSelection.setDatepickerTitle(withDate: searchTime, withSearchTimeType: searchTimeType)
        }

        searchForRoutes()
        
        routeTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateAllRoutesLiveTracking(sender:)), userInfo: nil, repeats: true)
        updateTimer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(rerenderLiveTracking(sender:)), userInfo: nil, repeats: true)

        // Check for 3D Touch availability
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }

        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupReachability()
        setUpRouteRefreshing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Takedown reachability
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        // Remove banner
        banner?.dismiss()
        banner = nil
        routeTimer?.invalidate()
        updateTimer?.invalidate()
        // Stop observing when app becomes active 
        NotificationCenter.default.removeObserver(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return banner != nil ? .lightContent : .default
    }

    private func setupRouteSelection(destination: Place?) {
        routeSelection.configure(delegate: self,
                                 from: Constants.General.fromSearchBarPlaceholder,
                                 to: destination?.name ?? "")

        view.addSubview(routeSelection)
    }

    private func setupRouteResultsTableView() {
        routeResults.delegate = self
        routeResults.allowsSelection = true
        routeResults.dataSource = self
        routeResults.separatorStyle = .none
        routeResults.backgroundColor = Colors.backgroundWash
        routeResults.alwaysBounceVertical = true
        routeResults.showsVerticalScrollIndicator = false
        routeResults.estimatedRowHeight = estimatedRowHeight
        routeResults.rowHeight = UITableView.automaticDimension
        routeResults.emptyDataSetSource = self
        routeResults.emptyDataSetDelegate = self
        routeResults.contentOffset = .zero
        routeResults.register(RouteTableViewCell.self, forCellReuseIdentifier: Constants.Cells.routeOptionsCellIdentifier)

        setupRefreshControl()

        view.addSubview(routeResults)
    }

    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func setupDatePicker() {
        setupDatePickerView()
        setupDatePickerOverlay()
    }

    private func setupDatePickerView() {
        datePickerView = DatePickerView(delegate: self)
        view.addSubview(datePickerView) // so datePicker can go ontop of other views
    }

    private func setupDatePickerOverlay() {
        datePickerOverlay.backgroundColor = Colors.black
        datePickerOverlay.alpha = 0
        datePickerOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissDatePicker)))
        view.addSubview(datePickerOverlay)
        view.sendSubviewToBack(datePickerOverlay)
    }

    private func setupSearchBar() {
        searchBarView = SearchBarView(searchBarCancelDelegate: self, destinationDelegate: self)
        self.definesPresentationContext = true
        hideSearchBar()
    }

    private func setUpRouteRefreshing() {
        let now = Date()
        let hourMinuteComponents: Set<Calendar.Component> = [.hour, .minute]
        let nowTime = Calendar.current.dateComponents(hourMinuteComponents, from: now)
        let lastRefreshTime = Calendar.current.dateComponents(hourMinuteComponents, from: lastRouteRefreshDate)
        if nowTime != lastRefreshTime {
            refreshRoutesAndTime()
        }

        let appBecameActiveNotification = UIApplication.didBecomeActiveNotification
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRoutesAndTime), name: appBecameActiveNotification, object: nil)
    }

    func setupConstraintsForVisibleDatePickerView() {
        datePickerView.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.datePickerView.frame.height)
        }
    }

    func setupConstraintsForHiddenDatePickerView() {
        datePickerView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.datePickerView.frame.height)
        }
    }

    private func setupConstraints() {
        routeSelection.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(routeResults.snp.top)
        }

        routeResults.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(routeSelection.snp.bottom)
        }

        datePickerView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        datePickerOverlay.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(routeSelection)
        }
    }

    func presentSearchBar() {
        var placeholder = ""
        var searchBarText = ""

        switch searchType {

        case .from:

            if
                let startingDestinationName = searchFrom?.name,
                startingDestinationName != Constants.General.currentLocation &&
                startingDestinationName != Constants.General.fromSearchBarPlaceholder
            {
                searchBarText = startingDestinationName
            }
            placeholder = Constants.General.fromSearchBarPlaceholder

        case .to:
            let endingDestinationName = searchTo.name
            if endingDestinationName != Constants.General.currentLocation {
                searchBarText = endingDestinationName
            }
            placeholder = Constants.General.toSearchBarPlaceholder

        }

        if let textFieldInsideSearchBar = searchBarView.searchController?.searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string: placeholder) // make placeholder invisible
            textFieldInsideSearchBar.text = searchBarText
        }

        showSearchBar()
    }

    func dismissSearchBar() {
        searchBarView.searchController?.dismiss(animated: true, completion: nil)
    }

    func hideSearchBar() {
        navigationItem.searchController = nil
        // After removing searchController from navigation bar, we need to call
        // setNeedsLayout in order to restore the navigation bar to its original height
        navigationController?.view.setNeedsLayout()
        if let backButton = backButton {
            navigationItem.setLeftBarButton(backButton, animated: false)
        }
        navigationItem.hidesBackButton = false
        searchBarView.searchController?.isActive = false
    }

    private func showSearchBar() {
        navigationItem.searchController = searchBarView.searchController
        // After adding searchController to navigation bar, we need to call
        // setNeedsLayout in order to for the navigation bar to increase its height
        // to account for the search bar
        navigationController?.view.setNeedsLayout()
        backButton = navigationItem.leftBarButtonItem
        navigationItem.setLeftBarButton(nil, animated: false)
        navigationItem.hidesBackButton = true
        searchBarView.searchController?.isActive = true
    }
    
    @objc func rerenderLiveTracking(sender: Timer) {
        // Reload table every time update timer is fired
        routeResults.reloadData()
    }
    
    private func getAllDelays(trips: [Trip]) -> Future<Response<[Delay]>> {
        return networking(Endpoint.getAllDelays(trips: trips)).decode()
    }
    
    @objc func updateAllRoutesLiveTracking(sender: Timer) {
        getAllDelays(trips: trips).observe(with: { result in
            DispatchQueue.main.async {
                switch result {
                    case .value(let delaysResponse):
                        if !delaysResponse.success { return }
                        let allDelays = delaysResponse.data
                        for delayResponse in allDelays {
                            let tripRoute = self.tripDictionary[delayResponse.tripID]
                            guard let route = tripRoute,
                                let routeId = tripRoute?.routeId,
                                let direction = route.getFirstDepartRawDirection(),
                                let delay = delayResponse.delay else {
                                    continue
                            }
                            let fileName = "RouteTableViewCell"
                            let isNewDelayValue = route.getFirstDepartRawDirection()?.delay != delay
                            if isNewDelayValue {
                                JSONFileManager.shared.logDelayParameters(timestamp: Date(), stopId: delayResponse.stopID, tripId: delayResponse.tripID)
                                JSONFileManager.shared.logURL(timestamp: Date(), urlName: "Delay requestUrl", url: Endpoint.getDelayUrl(tripId: delayResponse.tripID, stopId: delayResponse.stopID))
                                if let data = try? JSONEncoder().encode(delayResponse) {
                                    do { try JSONFileManager.shared.saveJSON(JSON.init(data: data), type: .delayJSON(routeId: routeId)) } catch let error {
                                        let line = "\(fileName) \(#function): \(error.localizedDescription)"
                                        print(line)
                                    }
                                }
                            }
                            let departTime = direction.startTime
                            let delayedDepartTime = departTime.addingTimeInterval(TimeInterval(delay))
                            var delayState: DelayState!
                            let isLateDelay = Time.compare(date1: delayedDepartTime, date2: departTime) == .orderedDescending
                            if isLateDelay {
                                delayState = DelayState.late(date: delayedDepartTime)
                            } else {
                                delayState = DelayState.onTime(date: departTime)
                            }
                            self.delayDictionary[routeId] = delayState
                            route.getFirstDepartRawDirection()?.delay = delay
                        }
                    case .error(let error):
                        print(error)
                    }
                }
            })
    }

//    @objc func updateLiveTracking(sender: Timer) {
        // For each route in each route array inside of the 'routes' array,
        // retrieve its delay. Use index of route to save delay for route to
        // JSON file.
//        updateAllRoutesLiveTracking()
//        for routesArray in routes {
//            for (index, route) in routesArray.enumerated() {
//                if !route.isRawWalkingRoute() {
//                    guard let direction = route.getFirstDepartRawDirection(),
//                        let tripId = direction.tripIdentifiers?.first,
//                        let stopId = direction.stops.first?.id else {
//                            return
//                    }
//                    getDelay(tripId: tripId, stopId: stopId).observe(with: { result in
//                        let fileName = "RouteTableViewCell"
//                        DispatchQueue.main.async {
//                            switch result {
//                            case .value (let delayResponse):
//                                guard delayResponse.data != nil, let delay = delayResponse.data else {
//                                    return
//                                }
//                                let isNewDelayValue = route.getFirstDepartRawDirection()?.delay != delay
//                                if isNewDelayValue {
//                                    JSONFileManager.shared.logDelayParemeters(timestamp: Date(), stopId: stopId, tripId: tripId)
//                                    JSONFileManager.shared.logURL(timestamp: Date(), urlName: "Delay requestUrl", url: Endpoint.getDelayUrl(tripId: tripId, stopId: stopId))
//                                    if let data = try? JSONEncoder().encode(delayResponse) {
//                                        do { try JSONFileManager.shared.saveJSON(JSON.init(data: data), type: .delayJSON(rowNum: index)) } catch let error {
//                                            let line = "\(fileName) \(#function): \(error.localizedDescription)"
//                                            print(line)
//                                        }
//                                    }
//                                }
//                                let departTime = direction.startTime
//                                let delayedDepartTime = departTime.addingTimeInterval(TimeInterval(delay))
//                                var delayState: DelayState!
//                                let isLateDelay = Time.compare(date1: delayedDepartTime, date2: departTime) == .orderedDescending
//                                if isLateDelay {
//                                    delayState = DelayState.late(date: delayedDepartTime)
//                                } else {
//                                    delayState = DelayState.onTime(date: departTime)
//                                }
//                                self.delayDictionary[route.routeId] = delayState
//                                route.getFirstDepartRawDirection()?.delay = delay
//
//                            case .error (let error):
//                                print(error)
//                            }
//                        }
//                    })
//                }
//            }
//        }
//    }
    
    @objc private func refreshRoutesAndTime() {
        let now = Date()
        if let leaveDate = searchTime,
            searchTimeType != .leaveNow,
            leaveDate.compare(now) == .orderedDescending {
            return
        }

        searchTime = now
        searchTimeType = .leaveNow
        routeSelection.setDatepickerTitle(withDate: now, withSearchTimeType: searchTimeType)
        searchForRoutes()
    }

    private func resetAndShowCurrentlyLoading() {
        showRouteSearchingLoader = true
        self.hideRefreshControl()

        routes = []
        routeResults.contentOffset = .zero
        routeResults.reloadData()
    }

    func searchForRoutes() {
        if let searchFrom = searchFrom,
            let searchTo = searchTo,
            let time = searchTime {
            let now = Date()
            lastRouteRefreshDate = now
            resetAndShowCurrentlyLoading()

            switch searchType {
            case .from:
                routeSelection.updateSearchBarTitles(from: searchFrom.name)
            case .to:
                routeSelection.updateSearchBarTitles(to: searchTo.name)
            }

            // Prepare feedback on Network request
            mediumTapticGenerator.prepare()

            JSONFileManager.shared.logSearchParameters(timestamp: now, startPlace: searchFrom, endPlace: searchTo, searchTime: time, searchTimeType: searchTimeType)

            // MARK: Search For Routes Errors
            
            guard let areValidCoordinates = self.checkPlaceCoordinates(startPlace: searchFrom, endPlace: searchTo) else {
                // Place(s) don't have coordinates assigned
                self.requestDidFinish(perform: [
                    .showError(bannerInfo: BannerInfo(title: Constants.Banner.routeCalculationError, style: .danger),
                               payload: GetRoutesErrorPayload(type: "Nil Place Coordinates",
                                                              description: "Place(s) don't have coordinates. (areValidCoordinates)", url: nil))
                    ])
                return
            }

            if !areValidCoordinates {
                // Coordinates are out of range.
                let title = Constants.Alerts.OutOfRange.title
                let message = Constants.Alerts.OutOfRange.message
                let actionTitle = Constants.Alerts.OutOfRange.action

                self.requestDidFinish(perform: [
                    .showAlert(title: title, message: message, actionTitle: actionTitle),
                    .showError(bannerInfo: BannerInfo(title: title, style: .warning),
                               payload: GetRoutesErrorPayload(type: title, description: message, url: nil))
                    ])
                return
            }

            // MARK: Search for Routes Data Request
            if let result =  getRoutes(start: searchFrom, end: searchTo, time: time, type: self.searchTimeType) {
                result.observe(with: { [weak self] result in
                    guard let `self` = self else { return }
                    DispatchQueue.main.async {
                        let requestURL = Endpoint.getRequestURL(start: searchFrom, end: searchTo, time: time, type: self.searchTimeType)
                        self.processRequest(result: result, requestURL: requestURL, endPlace: searchTo)
                    }
                })
            }

            // Donate GetRoutes intent
            if #available(iOS 12.0, *) {
                let intent = GetRoutesIntent()
                intent.searchTo = searchTo.name
                if let latitude = searchTo.latitude, let longitude = searchTo.longitude {
                    intent.latitude = String(describing: latitude)
                    intent.longitude = String(describing: longitude)
                }
                intent.suggestedInvocationPhrase = "Find bus to \(searchTo.name)"
                let interaction = INInteraction(intent: intent, response: nil)
                interaction.donate(completion: { (error) in
                    guard let error = error else { return }
                    print("Intent Donation Error: \(error.localizedDescription)")
                })
            }
        }
    }

    private func getRoutes(start: Place,
                           end: Place,
                           time: Date,
                           type: SearchType) -> Future<Response<RouteSectionsObject>>? {
        if let endpoint = Endpoint.getRoutes(start: start, end: end, time: time, type: type) {
            return networking(endpoint).decode()
        } else { return nil }
    }

    func routeSelected(routeId: String) {
        networking(Endpoint.routeSelected(routeId: routeId)).observe { [weak self] result in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .value:
                    self.printClass(context: "\(#function)", message: "success")
                case .error(let error):
                    self.printClass(context: "\(#function) error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func getRoutesTrips() {
        // For each route in each route array inside of the 'routes' array, get its
        // tripId and stopId to create trip array for request to get all delays.
        for routesArray in routes {
            for route in routesArray {
                if !route.isRawWalkingRoute() {
                    guard let direction = route.getFirstDepartRawDirection(),
                        let tripId = direction.tripIdentifiers?.first,
                        let stopId = direction.stops.first?.id else {
                            return
                    }
                    tripDictionary[tripId] = route
                    let trip = Trip(stopID: stopId, tripID: tripId)
                    trips.append(trip)
                }
            }
        }
    }
    
    private func processRequest(result: Result<Response<RouteSectionsObject>>, requestURL: String, endPlace: Place) {
        JSONFileManager.shared.logURL(timestamp: Date(), urlName: "Route requestUrl", url: requestURL)

        switch result {
        case .value(let response):

            // Save to JSONFileManager
            if let data = try? JSONEncoder().encode(response) {
                do { try JSONFileManager.shared.saveJSON(JSON.init(data: data), type: .routeJSON) } catch let error {
                    printClass(context: "\(#function) error", message: error.localizedDescription)
                }
            }
            // Parse sections of routes
            [response.data.fromStop, response.data.boardingSoon, response.data.walking]
                .forEach { (routeSection) in
                    routeSection.forEach { (route) in
                        route.formatDirections(start: self.searchFrom?.name, end: self.searchTo.name)
                    }
                    // Allow for custom display in search results for fromStop.
                    // We want to display a [] if a bus stop is the origin and doesn't exist
                    if !routeSection.isEmpty || self.searchFrom?.type == .busStop {
                        self.routes.append(routeSection)
                    }

            }
            self.getRoutesTrips()
            self.requestDidFinish(perform: [.hideBanner])
        case .error(let error):
            self.processRequestError(error: error, requestURL: requestURL)
        }
        let payload = DestinationSearchedEventPayload(destination: endPlace.name, requestUrl: requestURL)
        Analytics.shared.log(payload)
    }

    private func processRequestError(error: Error, requestURL: String) {
        let title = "Network Failure: \((error as NSError?)?.domain ?? "No Domain")"
        let description = (error.localizedDescription) + ", " + ((error as NSError?)?.description ?? "n/a")

        routes = []
        requestDidFinish(perform: [
            .showError(bannerInfo: BannerInfo(title: Constants.Banner.cantConnectServer, style: .danger),
                       payload: GetRoutesErrorPayload(type: title, description: description, url: requestURL))
        ])
    }

    /// Returns whether coordinates are valid, checking country extremes. Returns nil if places don't have coordinates.
    private func checkPlaceCoordinates(startPlace: Place, endPlace: Place) -> Bool? {

        guard
            let startCoordLatitude = startPlace.latitude,
            let startCoordLongitude = startPlace.longitude,
            let endCoordLatitude = endPlace.latitude,
            let endCoordLongitude = endPlace.longitude
            else {
                return nil
        }

        let latitudeValues = [startCoordLatitude, endCoordLatitude]
        let longitudeValues  = [startCoordLongitude, endCoordLongitude]

        let validLatitudes = latitudeValues.reduce(true) { (result, latitude) -> Bool in
            return result && latitude <= Constants.Values.RouteBorders.northBorder &&
                latitude >= Constants.Values.RouteBorders.southBorder
        }

        let validLongitudes = longitudeValues.reduce(true) { (result, longitude) -> Bool in
            return result && longitude <= Constants.Values.RouteBorders.eastBorder &&
                longitude >= Constants.Values.RouteBorders.westBorder
        }

        return validLatitudes && validLongitudes
    }

    private func requestDidFinish(perform actions: [RequestAction]) {

        for action in actions {

            switch action {

            case .showAlert(title: let title, message: let message, actionTitle: let actionTitle):
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: actionTitle, style: .cancel, handler: nil)
                alertController.addAction(action)
                present(alertController, animated: true, completion: nil)

            case .showError(bannerInfo: let bannerInfo, payload: let payload):
                banner = StatusBarNotificationBanner(title: bannerInfo.title, style: bannerInfo.style)
                banner?.autoDismiss = false
                banner?.dismissOnTap = true
                banner?.show(queuePosition: .front, on: navigationController)

                Analytics.shared.log(payload)

            case .hideBanner:
                banner?.dismiss()
                banner = nil
                NotificationBannerQueue.default.removeAll()
                mediumTapticGenerator.impactOccurred()

            }

        }

        showRouteSearchingLoader = false
        routeResults.reloadData()
    }

    // MARK: Reachability

    private func setupReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            printClass(context: "\(#function)", message: "Could not start reachability notifier")
        }
    }

    @objc private func reachabilityChanged(notification: Notification) {
        if let reachability = notification.object as? Reachability {

            // Dismiss current banner, if any
            banner?.dismiss()
            banner = nil

            switch reachability.connection {
            case .none:
                banner = StatusBarNotificationBanner(title: Constants.Banner.noInternetConnection, style: .danger)
                banner?.autoDismiss = false
                banner?.show(queuePosition: .front, bannerPosition: .top, on: navigationController)
                setUserInteraction(to: false)
            case .cellular, .wifi:
                setUserInteraction(to: true)
            }
        }
    }

    private func setUserInteraction(to userInteraction: Bool) {
        cellUserInteraction = userInteraction

        for cell in routeResults.visibleCells {
            setCellUserInteraction(cell, to: userInteraction)
        }

        routeSelection.isUserInteractionEnabled = userInteraction
    }

    func setCellUserInteraction(_ cell: UITableViewCell?, to userInteraction: Bool) {
        cell?.isUserInteractionEnabled = userInteraction
        cell?.selectionStyle = .none // userInteraction ? .default : .none
    }

    // MARK: Refresh Control

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.isHidden = true

        routeResults.refreshControl = refreshControl
    }

    private func hideRefreshControl() {
        routeResults.refreshControl?.endRefreshing()
    }

    // MARK: RouteDetailViewController

    func createRouteDetailViewController(from indexPath: IndexPath) -> RouteDetailViewController? {

        let route = routes[indexPath.section][indexPath.row]
        var routeDetailCurrentLocation = currentLocation
        if searchTo.name != Constants.General.currentLocation && searchFrom?.name != Constants.General.currentLocation {
            routeDetailCurrentLocation = nil // If route doesn't involve current location, don't pass along for view.
        }

        let routeOptionsCell = routeResults.cellForRow(at: indexPath) as? RouteTableViewCell

        let contentViewController = RouteDetailContentViewController(route: route,
                                                                     currentLocation: routeDetailCurrentLocation,
                                                                     routeOptionsCell: routeOptionsCell)

        guard let drawerViewController = contentViewController.getDrawerDisplayController() else {
            return nil
        }
        return RouteDetailViewController(contentViewController: contentViewController,
                                         drawerViewController: drawerViewController)
    }
}
