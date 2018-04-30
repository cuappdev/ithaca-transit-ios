//
//  RouteOptionsViewController.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import DZNEmptyDataSet
import NotificationBannerSwift
import Crashlytics
import Pulley
import SwiftRegister
import TRON

enum SearchBarType: String {
    case from, to
}

enum SearchType: String {
    case arriveBy, leaveAt, leaveNow
}

struct BannerInfo {
    let title: String
    let style: BannerStyle
}

enum RequestAction {
    case showAlert(title: String, message: String, actionTitle: String)
    case showError(bannerInfo: BannerInfo, payload: GetRoutesErrorPayload)
    case hideBanner
}

class RouteOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                                  DestinationDelegate, SearchBarCancelDelegate,
                                  DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,
                                  CLLocationManagerDelegate,
                                  UIViewControllerPreviewingDelegate {
    
    // MARK: Search bar vars

    var searchBarView: SearchBarView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D?
    var searchType: SearchBarType = .from
    var searchTimeType: SearchType = .leaveNow
    var searchFrom: Place?
    var searchTo: Place?
    var searchTime: Date?
    var showRouteSearchingLoader: Bool = false

    // MARK: View vars
    
    let mediumTapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    var routeSelection: RouteSelectionView!
    var datePickerView: DatePickerView!
    var datePickerOverlay: UIView!
    var routeResults: UITableView!
    var refreshControl: UIRefreshControl!

    let navigationBarTitle: String = "Route Options"
    let routeResultsTitle: String = "Route Results"

    // MARK:  Data vars

    var routes: [Route] = []
    var invalidateTimers: Bool = false

    // MARK: Reachability vars

    let reachability: Reachability? = Reachability(hostname: Network.ipAddress)

    var banner: StatusBarNotificationBanner? = nil

    var isBannerShown: Bool = false
    var cellUserInteraction: Bool = true
    
    // MARK: Spacing vars
    
    let estimatedRowHeight: CGFloat = 115
    
    // MARK: Print vars
    
    private let fileName: String = "RouteOptionsVc"

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .tableBackgroundColor

        edgesForExtendedLayout = []

        title = navigationBarTitle

        setupRouteSelection()
        setupSearchBar()
        setupDatePicker()
        setupRouteResultsTableView()
        setupEmptyDataSet()

        view.addSubview(routeSelection)
        view.addSubview(datePickerOverlay)
        view.sendSubview(toBack: datePickerOverlay)
        view.addSubview(routeResults)
        view.addSubview(datePickerView) // so datePicker can go ontop of other views

        setRouteSelectionView(withDestination: searchTo)
        setupLocationManager()

        // assume user wants to find routes that leave at current time and set datepicker accordingly
        searchTime = Date()
        if let searchTime = searchTime {
            routeSelection.setDatepicker(withDate: searchTime, withSearchTimeType: searchTimeType)
        }
        
        searchForRoutes()
        
        // Check for 3D Touch availability
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        routeResults.register(RouteTableViewCell.self, forCellReuseIdentifier: RouteTableViewCell.identifier)
        setupReachability()
        
        invalidateTimers = false
        if routes != [] {
            routeResults.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11, *) {
            addHeightToDatepicker(20) // add bottom padding to date picker for iPhone X
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        takedownReachability()
        if isBannerShown {
            banner?.dismiss()
            banner = nil
            UIApplication.shared.statusBarStyle = .default
        }
        
        invalidateTimers = true
        if routes != [] {
            routeResults.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isBannerShown ? .lightContent : .default
    }

    // MARK: Route Selection view

    private func setupRouteSelection() {
        // offset for -12 for larger views, get rid of black space
        routeSelection = RouteSelectionView(frame: CGRect(x: 0, y: -12, width: view.frame.width, height: 150))
        routeSelection.backgroundColor = .white
        var newRSFrame = routeSelection.frame
        newRSFrame.size.height =  routeSelection.lineWidth + routeSelection.searcbarView.frame.height + routeSelection.lineWidth + routeSelection.datepickerButton.frame.height
        routeSelection.frame = newRSFrame

        routeSelection.toSearchbar.addTarget(self, action: #selector(self.searchingTo), for: .touchUpInside)
        routeSelection.fromSearchbar.addTarget(self, action: #selector(self.searchingFrom), for: .touchUpInside)
        routeSelection.datepickerButton.addTarget(self, action: #selector(self.showDatePicker), for: .touchUpInside)
        routeSelection.swapButton.addTarget(self, action: #selector(self.swapFromAndTo), for: .touchUpInside)
    }

    private func setRouteSelectionView(withDestination destination: Place?) {
        routeSelection.fromSearchbar.setTitle(Constants.Phrases.fromSearchBarPlaceholder, for: .normal)
        routeSelection.toSearchbar.setTitle(destination?.name ?? "", for: .normal)
    }

    @objc func swapFromAndTo(sender: UIButton) {
        //Swap data
        let searchFromOld = searchFrom
        searchFrom = searchTo
        searchTo = searchFromOld

        //Update UI
        routeSelection.fromSearchbar.setTitle(searchFrom?.name ?? "", for: .normal)
        routeSelection.toSearchbar.setTitle(searchTo?.name ?? "", for: .normal)

        searchForRoutes()
    }

    // MARK: Search bar

    private func setupSearchBar() {
        searchBarView = SearchBarView()
        searchBarView.resultsViewController?.destinationDelegate = self
        searchBarView.resultsViewController?.searchBarCancelDelegate = self
        searchBarView.searchController?.searchBar.sizeToFit()
        self.definesPresentationContext = true
        hideSearchBar()
    }

    @objc func searchingTo(sender: UIButton? = nil) {
        searchType = .to
        presentSearchBar()
    }

    @objc func searchingFrom(sender: UIButton? = nil) {
        searchType = .from
        searchBarView.resultsViewController?.shouldShowCurrentLocation = true
        presentSearchBar()
    }

    func presentSearchBar() {
        var placeholder = ""
        var searchBarText = ""

        switch searchType {

        case .from:

            if let startingDestinationName = searchFrom?.name {
                if startingDestinationName != Constants.Stops.currentLocation && startingDestinationName != Constants.Phrases.fromSearchBarPlaceholder {
                    searchBarText = startingDestinationName
                }
            }
            placeholder = Constants.Phrases.fromSearchBarPlaceholder

        case .to:

            if let endingDestinationName = searchTo?.name {
                if endingDestinationName != Constants.Stops.currentLocation {
                    searchBarText = endingDestinationName
                }
            }
            placeholder = Constants.Phrases.toSearchBarPlaceholder

        }

        let textFieldInsideSearchBar = searchBarView.searchController?.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(string: placeholder) // make placeholder invisible
        textFieldInsideSearchBar?.text = searchBarText

        showSearchBar()
    }

    private func dismissSearchBar() {
        searchBarView.searchController?.dismiss(animated: true, completion: nil)
    }

    func didSelectDestination(busStop: BusStop?, placeResult: PlaceResult?) {

        switch searchType {

        case .from:

            if let result = busStop {
                searchFrom = result
                routeSelection.fromSearchbar.setTitle(result.name, for: .normal)
            }else if let result = placeResult{
                searchFrom = result
                routeSelection.fromSearchbar.setTitle(result.name, for: .normal)
            }

        case .to:

            if let result = busStop {
                searchTo = result
                routeSelection.toSearchbar.setTitle(result.name, for: .normal)
            }else if let result = placeResult {
                searchTo = result
                routeSelection.toSearchbar.setTitle(result.name, for: .normal)
            }
        }

        hideSearchBar()
        dismissSearchBar()
        searchForRoutes()
    }

    func didCancel() {
        hideSearchBar()
    }

    // Variable to remember back button when hiding
    var backButton: UIBarButtonItem? = nil

    private func hideSearchBar() {
        if #available(iOS 11.0, *) {
            navigationItem.searchController = nil
        } else {
            navigationItem.titleView = nil
        }
        if let backButton = backButton {
            navigationItem.setLeftBarButton(backButton, animated: false)
        }
        navigationItem.hidesBackButton = false
        searchBarView.searchController?.isActive = false
    }

    private func showSearchBar() {
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchBarView.searchController
        } else {
            navigationItem.titleView = searchBarView.searchController?.searchBar
        }
        backButton = navigationItem.leftBarButtonItem
        navigationItem.setLeftBarButton(nil, animated: false)
        navigationItem.hidesBackButton = true
        searchBarView.searchController?.isActive = true
    }

    // MARK: Process Data

    func searchForRoutes() {
      
        if let searchFrom = searchFrom,
           let searchTo = searchTo,
           let time = searchTime,
           let startPlace = searchFrom as? CoordinateAcceptor,
           let endPlace = searchTo as? CoordinateAcceptor {
            
            showRouteSearchingLoader = true
            self.hideRefreshControl()

            routes = []
            routeResults.contentOffset = .zero
            routeResults.reloadData()

            // Prepare feedback on Network request
            mediumTapticGenerator.prepare()

            JsonFileManager.shared.writeToLog(timestamp: Date(), line: "Search parameters: startPlace: \(searchFrom). endPlace: \(searchTo). searchTime: \(Time.dateString(from: time)). searchTimeType: \(searchTimeType)")
            
            let sameLocation = (searchFrom.name == searchTo.name)
            if sameLocation {
                requestDidFinish(perform: [.showAlert(title: "You're here!", message: "You have arrived at your destination. Thank you for using our TCAT Teleporation™ feature (beta).", actionTitle: "😐😒🙄")])
                return
            }
            
            Network.getCoordinates(start: startPlace, end: endPlace) { (startCoord, endCoord, coordinateVisitorError) in
                
                guard let startCoord = startCoord, let endCoord = endCoord else {
                    self.processNoCoordinates(coordinateVisitorError: coordinateVisitorError)
                    return
                }
                
                if !self.validCoordinates(startCoord: startCoord, endCoord: endCoord) {
                    self.processInvalidCoordinates()
                    return
                }
                
                Network.getRoutes(startCoord: startCoord, endCoord: endCoord, endPlaceName: searchFrom.name, time: time, type: self.searchTimeType) { request in
                    let requestUrl = Network.getRequestUrl(startCoord: startCoord, endCoord: endCoord, destinationName: searchTo.name, time: time, type: self.searchTimeType)
                    self.processRequest(request: request, requestUrl: requestUrl, endPlace: searchFrom)
                }
                
            }
        }
    }
    
    func processNoCoordinates(coordinateVisitorError: CoordinateVisitorError?) {
        if let coordinateVisitorError = coordinateVisitorError {
            
            self.requestDidFinish(perform: [
                .showError(bannerInfo: BannerInfo(title: "Could not connect to server", style: .danger),
                           payload: GetRoutesErrorPayload(type: coordinateVisitorError.title, description: coordinateVisitorError.description, url: nil))
                ])
            
        } else {
            
            self.requestDidFinish(perform: [
                .showError(bannerInfo: BannerInfo(title: "Could not connect to server", style: .danger),
                           payload: GetRoutesErrorPayload(type: "Nil start and end coordinates and nil coordinateVisitorError", description: "", url: nil))
                ])
            
        }
    }
    
    func processInvalidCoordinates() {
        let title = "Location Out Of Range"
        let message = "Try looking for another route with start and end locations closer to Tompkins County."
        let actionTitle = "OK"
        
        self.requestDidFinish(perform: [
            .showAlert(title: title, message: message, actionTitle: actionTitle),
            .showError(bannerInfo: BannerInfo(title: title, style: .warning),
                       payload: GetRoutesErrorPayload(type: title, description: message, url: nil))
            ])
    }
    
    func processRequest(request: APIRequest<JSON, Error>, requestUrl: String, endPlace: Place) {
        JsonFileManager.shared.writeToLog(timestamp: Date(), line: "Route requestUrl: \(requestUrl)")
        
        request.perform(withSuccess: { routeJson in
                            self.processRouteJson(routeJSON: routeJson, requestUrl: requestUrl)
                        },
                        failure: { requestError in
                            self.processRequestError(error: requestError, requestUrl: requestUrl)
                        }
        )
        
        let payload = DestinationSearchedEventPayload(destination: endPlace.name,
                                                      requestUrl: requestUrl,
                                                      stopType: nil)
        RegisterSession.shared?.log(payload)
    }
    
    func processRouteJson(routeJSON: JSON, requestUrl: String) {
        JsonFileManager.shared.saveToDocuments(json: routeJSON, type: .routeJson)
        
        JsonFileManager.shared.printAllJsons()
        if let log = JsonFileManager.shared.readFromLog() {
            print(log)
        }
        
        Route.parseRoutes(in: routeJSON, from: self.searchFrom?.name, to: self.searchTo?.name, { (parsedRoutes, error) in
            self.routes = parsedRoutes
            
            if let error = error {
                self.requestDidFinish(perform: [
                    .showError(bannerInfo: BannerInfo(title: "Route calculation error. Please retry.", style: .warning),
                               payload: GetRoutesErrorPayload(type: error.title, description: error.description, url: requestUrl))
                ])
            }
            else {
                self.requestDidFinish(perform: [.hideBanner])
            }
        })
    }
    
    func processRequestError(error: APIError<Error>, requestUrl: String) {
        let title = "Network Failure: \((error.error as NSError?)?.domain ?? "No Domain")"
        let description = (error.localizedDescription) + ", " + ((error.error as NSError?)?.description ?? "n/a")
        
        self.routes = []
        self.requestDidFinish(perform: [
            .showError(bannerInfo: BannerInfo(title: "Could not connect to server", style: .danger),
                       payload: GetRoutesErrorPayload(type: title, description: description, url: requestUrl))
        ])
    }
    
    func validCoordinates(startCoord: CLLocationCoordinate2D, endCoord: CLLocationCoordinate2D) -> Bool {
        let latitudeValues = [startCoord.latitude, endCoord.latitude]
        let longitudeValues  = [startCoord.longitude, endCoord.longitude]
        
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
    
    func requestDidFinish(perform actions: [RequestAction]) {
        
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
                isBannerShown = true
                
                RegisterSession.shared?.log(payload)
                
            case .hideBanner:
                if isBannerShown {
                    isBannerShown = false
                    banner?.dismiss()
                    banner = nil
                }
                mediumTapticGenerator.impactOccurred()
                
            }
            
        }
        
        UIApplication.shared.statusBarStyle = preferredStatusBarStyle
        showRouteSearchingLoader = false
        routeResults.reloadData()
    }

    // MARK: Location Manager Delegate

    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("\(fileName) \(#function): \(error.localizedDescription)")
        
        if error._code == CLError.denied.rawValue {
            locationManager.stopUpdatingLocation()
            
            let alertController = UIAlertController(title: "Location Services Disabled", message: "Tap Settings to change your location permissions, or continue using a limited version of the app.", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: "App-prefs:root=LOCATION_SERVICES") ?? URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            }
            
            guard let showReminder = userDefaults.value(forKey: Constants.UserDefaults.showLocationAuthReminder) as? Bool else {
                
                userDefaults.set(true, forKey: Constants.UserDefaults.showLocationAuthReminder)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                
                alertController.addAction(settingsAction)
                alertController.preferredAction = settingsAction
                
                present(alertController, animated: true)
                
                return
            }
            
            if !showReminder {
                return
            }
            
            let dontRemindAgainAction = UIAlertAction(title: "Don't Remind Me Again", style: .default) { (_) in
                userDefaults.set(false, forKey: Constants.UserDefaults.showLocationAuthReminder)
            }
            alertController.addAction(dontRemindAgainAction)
            
            alertController.addAction(settingsAction)
            alertController.preferredAction = settingsAction
            
            present(alertController, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return
        }
        
        currentLocation = location.coordinate
        
        updateSearchBarCurrentLocation(withCoordinate: location.coordinate)
        
        if let busStop = searchTo as? BusStop {
            if busStop.name == Constants.Stops.currentLocation {
               updateCurrentLocation(busStop, withCoordinate: location.coordinate)
            }
        }
        
        if let busStop = searchFrom as? BusStop {
            if busStop.name == Constants.Stops.currentLocation {
                updateCurrentLocation(busStop, withCoordinate: location.coordinate)
            }
        }
        
        // If haven't selected start location, set to current location
        if searchFrom == nil {
            let currentLocationStop = BusStop(name: Constants.Stops.currentLocation,
                                              lat: location.coordinate.latitude,
                                              long: location.coordinate.longitude)
            searchFrom = currentLocationStop
            searchBarView.resultsViewController?.currentLocation = currentLocationStop
            routeSelection.fromSearchbar.setTitle(currentLocationStop.name, for: .normal)
            searchForRoutes()
        }
    }
    
    private func updateCurrentLocation(_ currentLocationStop: BusStop, withCoordinate coordinate: CLLocationCoordinate2D ) {
        currentLocationStop.lat = coordinate.latitude
        currentLocationStop.long = coordinate.longitude
    }
    
    private func updateSearchBarCurrentLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        searchBarView.resultsViewController?.currentLocation?.lat = coordinate.latitude
        searchBarView.resultsViewController?.currentLocation?.long = coordinate.longitude
    }

    // MARK: Date Picker

    private func setupDatePicker() {
        setupDatePickerView()
        setupDatePickerOverlay()
    }

    private func setupDatePickerView() {
        datePickerView = DatePickerView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 254))

        datePickerView.positionSubviews()
        datePickerView.addSubviews()

        datePickerView.cancelButton.addTarget(self, action: #selector(self.dismissDatePicker), for: .touchUpInside)
        datePickerView.doneButton.addTarget(self, action: #selector(self.saveDatePickerDate), for: .touchUpInside)
    }

    private func setupDatePickerOverlay() {
        datePickerOverlay = UIView(frame: CGRect(x: 0, y: -12, width: view.frame.width, height: view.frame.height + 12)) // 12 for sliver that shows up when click datepicker immediately after transition from HomeVC
        datePickerOverlay.backgroundColor = .black
        datePickerOverlay.alpha = 0

        datePickerOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissDatePicker)))
    }

    private func addHeightToDatepicker(_ height: CGFloat) {
        let oldFrame = datePickerView.frame
        let newFrame = CGRect(x: oldFrame.minX, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height + height)

        datePickerView.frame = newFrame
    }

    @objc func showDatePicker(sender: UIButton) {
        
        view.bringSubview(toFront: datePickerOverlay)
        view.bringSubview(toFront: datePickerView)

        // set up date on datepicker view
        if let time = searchTime  {
            datePickerView.setDatepickerDate(date: time)
        }

        datePickerView.setDatepickerTimeType(searchTimeType: searchTimeType)

        UIView.animate(withDuration: 0.5) {
            self.datePickerView.center.y = self.view.frame.height - (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.6 // darken screen when pull up datepicker
        }
        
        let payload = DatePickerAccessedPayload()
        RegisterSession.shared?.log(payload)
        
    }

    @objc func dismissDatePicker(sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.datePickerView.center.y = self.view.frame.height + (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.0
        }) { (completion) in
            self.view.sendSubview(toBack: self.datePickerOverlay)
            self.view.sendSubview(toBack: self.datePickerView)
        }
    }

    @objc func saveDatePickerDate(sender: UIButton) {
        let date = datePickerView.getDate()
        searchTime = date
        
        let typeToSegmentControlElements = datePickerView.typeToSegmentControlElements
        let timeTypeSegmentControl = datePickerView.timeTypeSegmentedControl
        let leaveNowSegmentControl = datePickerView.leaveNowSegmentedControl
        
        // Get selected time type
        if leaveNowSegmentControl.selectedSegmentIndex == typeToSegmentControlElements[.leaveNow]!.index {
            searchTimeType = .leaveNow
        }
        else if timeTypeSegmentControl.selectedSegmentIndex == typeToSegmentControlElements[.arriveBy]!.index {
            searchTimeType = .arriveBy
        }else{
            searchTimeType = .leaveAt
        }
        
        routeSelection.setDatepicker(withDate: date, withSearchTimeType: searchTimeType)

        dismissDatePicker(sender: sender)
        
        searchForRoutes()
    }
    
    // MARK: Tableview Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return routes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: RouteTableViewCell.identifier, for: indexPath) as? RouteTableViewCell

        if cell == nil {
            cell = RouteTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: RouteTableViewCell.identifier)
        }

        cell?.setData(route: routes[indexPath.row], rowNum: indexPath.row, invalidateTimers: invalidateTimers)
        cell?.addRouteDiagramSubviews()
        cell?.activateRouteDiagramConstraints()

        // Add share action for long press gestures on non 3D Touch devices
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        cell?.addGestureRecognizer(longPressGestureRecognizer)
        
        setCellUserInteraction(cell, to: cellUserInteraction)
        
        return cell!
    }

    // MARK: Reachability

    private func setupReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: .reachabilityChanged, object: reachability)

        do {
            try reachability?.startNotifier()
        } catch {
            print("\(fileName) \(#function): Could not start reachability notifier")
        }
    }

    private func takedownReachability() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }

    @objc private func reachabilityChanged(_ notification: Notification) {

        let reachability = notification.object as! Reachability

        switch reachability.connection {

            case .none:
                banner = StatusBarNotificationBanner(title: Constants.Banner.noInternetConnection, style: .danger)
                banner!.autoDismiss = false
                banner!.show(queuePosition: .front, bannerPosition: .top, on: self.navigationController)
                isBannerShown = true
                setUserInteraction(to: false)

            case .cellular, .wifi:
                if isBannerShown {
                    banner?.dismiss()
                    banner = nil
                    isBannerShown = false
                }
                setUserInteraction(to: true)

        }

        UIApplication.shared.statusBarStyle = preferredStatusBarStyle

    }

    private func setUserInteraction(to userInteraction: Bool) {
        cellUserInteraction = userInteraction

        for cell in routeResults.visibleCells {
            setCellUserInteraction(cell, to: userInteraction)
        }

        routeSelection.isUserInteractionEnabled = userInteraction
    }

    private func setCellUserInteraction(_ cell: UITableViewCell?, to userInteraction: Bool) {
        cell?.isUserInteractionEnabled = userInteraction
        cell?.selectionStyle = .none // userInteraction ? .default : .none
    }

    // MARK: DZNEmptyDataSet

    private func setupEmptyDataSet() {
        routeResults.emptyDataSetSource = self
        routeResults.emptyDataSetDelegate = self
        routeResults.tableFooterView = UIView()
        routeResults.contentOffset = .zero
    }

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        
        let customView = UIView()
        var symbolView = UIView()

        if showRouteSearchingLoader {
            symbolView = LoadingIndicator()
        }  else {
            let imageView = UIImageView(image: #imageLiteral(resourceName: "road"))
            imageView.contentMode = .scaleAspectFit
            symbolView = imageView
        }

        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14.0)
        titleLabel.textColor = .mediumGrayColor
        titleLabel.text = showRouteSearchingLoader ? "Looking for routes..." : "No Routes Found"
        titleLabel.sizeToFit()

        customView.addSubview(symbolView)
        customView.addSubview(titleLabel)

        symbolView.snp.makeConstraints{ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(showRouteSearchingLoader ? -20 : -22.5)
            make.width.equalTo(showRouteSearchingLoader ? 40 : 45)
            make.height.equalTo(showRouteSearchingLoader ? 40 : 45)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(symbolView.snp.bottom).offset(10)
            make.centerX.equalTo(symbolView.snp.centerX)
        }

        return customView
    }
    
    // Allow for pull to refresh in empty state
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    // Allow for pull to refresh in empty state
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    // MARK: Tableview Delegate

    private func setupRouteResultsTableView() {
        routeResults = UITableView(frame: CGRect(x: 0, y: routeSelection.frame.maxY, width: view.frame.width, height: view.frame.height - routeSelection.frame.height - (navigationController?.navigationBar.frame.height ?? 0)), style: .plain)
        routeResults.delegate = self
        routeResults.allowsSelection = true
        routeResults.dataSource = self
        routeResults.separatorStyle = .none
        routeResults.backgroundColor = .tableBackgroundColor
        routeResults.alwaysBounceVertical = true //so table view doesn't scroll over top & bottom
        routeResults.showsVerticalScrollIndicator = false
        
        // so can have dynamic height cells
        routeResults.estimatedRowHeight = estimatedRowHeight
        routeResults.rowHeight = UITableViewAutomaticDimension
        
        setupRefreshControl()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        locationManager.stopUpdatingLocation()
        if let routeDetailViewController = createRouteDetailViewController(from: routes[indexPath.row]) {
            let payload = RouteResultsCellTappedEventPayload()
            RegisterSession.shared?.log(payload)
            navigationController?.pushViewController(routeDetailViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tableViewTopMargin: CGFloat = 12
        return UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: tableViewTopMargin))
    }
    
    // MARK: Refresh Control
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.isHidden = true
        
        if #available(iOS 10.0, *) {
            routeResults.refreshControl = refreshControl
        } else {
            routeResults.addSubview(refreshControl)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
            // Update leave now time in pull to refresh
            if searchTimeType == .leaveNow {
                let now = Date()
                searchTime = now
                routeSelection.setDatepicker(withDate: now, withSearchTimeType: searchTimeType)
            }
            
            searchForRoutes()
        }
    }
    
    func hideRefreshControl() {
        if #available(iOS 10.0, *) {
            routeResults.refreshControl?.endRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    // MARK: RouteDetailViewController
    
    func createRouteDetailViewController(from route: Route) -> RouteDetailViewController? {
        
        var routeDetailCurrentLocation = currentLocation
        if searchTo?.name != Constants.Stops.currentLocation && searchFrom?.name != Constants.Stops.currentLocation {
            routeDetailCurrentLocation = nil // If route doesn't involve current location, don't pass along.
        }
        
        let contentViewController = RouteDetailContentViewController(route: route, currentLocation: routeDetailCurrentLocation)
        guard let drawerViewController = contentViewController.drawerDisplayController else {
            return nil
        }
        return RouteDetailViewController(contentViewController: contentViewController,
                                         drawerViewController: drawerViewController)
    }
    
    // MARK: Previewing Delegate
    
    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: routeResults)
            if let indexPath = routeResults.indexPathForRow(at: point), let cell = routeResults.cellForRow(at: indexPath) {
                presentShareSheet(from: view, for: routes[indexPath.row], with: cell.getImage())
            }
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let point = view.convert(location, to: routeResults)
        
        guard
            let indexPath = routeResults.indexPathForRow(at: point),
            let cell = routeResults.cellForRow(at: indexPath) as? RouteTableViewCell,
            let routeDetailViewController = createRouteDetailViewController(from: routes[indexPath.row])
        else {
            return nil
        }
        
        routeDetailViewController.preferredContentSize = .zero
        routeDetailViewController.isPeeking = true
        cell.transform = .identity
        previewingContext.sourceRect = routeResults.convert(cell.frame, to: view)
        
        let payload = RouteResultsCellPeekedPayload()
        RegisterSession.shared?.log(payload)
        
        return routeDetailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        (viewControllerToCommit as? RouteDetailViewController)?.isPeeking = false
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}
