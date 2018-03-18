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

enum SearchBarType: String {
    case from, to
}

enum SearchType: String {
    case arriveBy, leaveAt
}

class RouteOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                                  DestinationDelegate, SearchBarCancelDelegate,
                                  DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,
                                  CLLocationManagerDelegate {
    
    // MARK: Search bar vars

    var searchBarView: SearchBarView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D?
    var searchType: SearchBarType = .from
    var searchTimeType: SearchType = .leaveAt
    var searchFrom: Place?
    var searchTo: Place?
    var searchTime: Date?
    var currentlySearching: Bool = false

    // MARK: View vars

    var routeSelection: RouteSelectionView!
    var datePickerView: DatePickerView!
    var datePickerOverlay: UIView!
    var routeResults: UITableView!
    var refreshControl = UIRefreshControl()

    let navigationBarTitle: String = "Route Options"
    let routeTableViewCellIdentifier: String = RouteTableViewCell().identifier
    let routeResultsTitle: String = "Route Results"
    let routeResultsHeaderHeight: CGFloat = 57.0

    // MARK:  Data vars

    var routes: [Route] = []

    // MARK: Reachability vars

    let reachability: Reachability? = Reachability(hostname: Network.ipAddress)

    var banner: StatusBarNotificationBanner? = nil

    var isBannerShown: Bool = false
    var cellUserInteraction: Bool = true

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .tableBackgroundColor

        edgesForExtendedLayout = []

        title = navigationBarTitle

        setupRouteSelection()
        setupSearchBar()
        setupDatepicker()
        setupRouteResultsTableView()
        setupEmptyDataSet()

        view.addSubview(routeSelection)
        view.addSubview(datePickerOverlay)
        view.sendSubview(toBack: datePickerOverlay)
        view.addSubview(routeResults)
        view.addSubview(datePickerView) //so datePicker can go ontop of other views

        setRouteSelectionView(withDestination: searchTo)
        setupLocationManager()

        searchForRoutes()
        
        // Check for 3D Touch availability
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        routeResults.register(RouteTableViewCell.self, forCellReuseIdentifier: routeTableViewCellIdentifier)
        setupReachability()
    }

    override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 11, *) {
            addHeightToDatepicker(20) // add bottom padding to date picker for iPhone X
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        takedownReachability()
        if isBannerShown {
            banner?.dismiss()
            banner = nil
            UIApplication.shared.statusBarStyle = .default
        }
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

    private func setRouteSelectionView(withDestination destination: Place?){
        routeSelection.toSearchbar.setTitle(destination?.name ?? "", for: .normal)
    }

    @objc func swapFromAndTo(sender: UIButton){
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
                if startingDestinationName != Constants.Stops.currentLocation {
                    searchBarText = startingDestinationName
                }
            }
            placeholder = "Choose starting point..."

        case .to:

            if let endingDestinationName = searchTo?.name {
                searchBarText = endingDestinationName
            }
            placeholder = "Choose destination..."

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

    // MARK: Process data

    func searchForRoutes() {
        
        // If no date is set then date should be same as today's date
        if routeSelection.datepickerButton.titleLabel?.text?.lowercased() == "leave now" {
            searchTime = Date()
        }

        if let time = searchTime,
            let startingDestination = searchFrom as? CoordinateAcceptor,
            let endingDestination = searchTo as? CoordinateAcceptor
        {

            routes = []
            currentlySearching = true
            routeResults.contentOffset = .zero
            routeResults.reloadData()

            // Check if to and from location is the same
            if searchFrom?.name != searchTo?.name {
                
                Network.getRoutes(start: startingDestination, end: endingDestination, time: time, type: searchTimeType) { request in
                    
                    if #available(iOS 10.0, *) {
                        self.routeResults.refreshControl?.endRefreshing()
                    } else {
                        self.refreshControl.endRefreshing()
                    }
                    
                    func requestDidFinish(with error: NSError? = nil) {
                        if let err = error {
                            
                            let message = err.code >= 400 ? "Could not connect to server" : "Route calculation error. Please retry."
                            let type: BannerStyle = err.code >= 400 ? .danger : .warning
                            
                            self.banner = StatusBarNotificationBanner(title: message, style: type)
                            self.banner?.autoDismiss = false
                            self.banner?.dismissOnTap = true
                            self.banner?.show(queuePosition: .front, on: self.navigationController)
                            self.isBannerShown = true
                            
                            let payload = GetRoutesErrorPayload(description: error?.userInfo["description"] as? String ?? "",
                                                                url: error?.userInfo["url"] as? String)
                            RegisterSession.shared?.logEvent(event: payload.toEvent())
                            
                        } else {
                            if self.isBannerShown {
                                self.isBannerShown = false
                                self.banner?.dismiss()
                                self.banner = nil
                            }
                        }
                        
                        UIApplication.shared.statusBarStyle = self.preferredStatusBarStyle
                        self.currentlySearching = false
                        self.routeResults.reloadData()
                        
                    }
                    
                    if let alamofireRequest = request?.perform(withSuccess: { (routeJSON) in
                        Route.parseRoutes(in: routeJSON, from: self.searchFrom?.name, to: self.searchTo?.name, { (parsedRoutes, error) in
                            self.routes = parsedRoutes
                            requestDidFinish(with: error) // 300 error
                        })
                    }, failure: { (networkError) in
                        let description = (networkError.errorDescription ?? "n/a") + " • " + (networkError.failureReason ?? "n/a")
                        let error = NSError(domain: "Network Failure", code: 500, userInfo: [
                            "description" : description,
                            "url" : networkError.request?.url?.absoluteString ?? "n/a"
                        ])
                        self.routes = []
                        requestDidFinish(with: error)
                    })
                    { // Handle non-null request
                        let event = DestinationSearchedEventPayload(destination: self.searchTo?.name ?? "",
                                                                    requestUrl: alamofireRequest.request?.url?.absoluteString,
                                                                    stopType: nil).toEvent()
                        RegisterSession.shared?.logEvent(event: event)
                    }
                        
                    else { // Catch error of coordinates not being found
                        let error = NSError(domain: "Null Coordinates", code: 400, userInfo: nil)
                        requestDidFinish(with: error)
                    }
                    
                }
                
            } // end conditional ehecking names
            
            else {
                
                let title = "You're here!"
                let message = "You have arrived at your destination. Thank you for using our TCAT Teleporation™ feature (beta)."
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "😐😒🙄", style: .cancel, handler: nil)
                alertController.addAction(action)
                present(alertController, animated: true, completion: nil)
                
                currentlySearching = false
                routeResults.reloadData()
                
            }

        } // end if let

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isBannerShown ? .lightContent : .default
    }

    // MARK: Location Manager Delegate

    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        
        print("RouteOptionVC locationManager didFailWithError: \(error.localizedDescription)")
        locationManager.stopUpdatingLocation()
        var boolean = true
        
        if let showReminder = userDefaults.value(forKey: Constants.UserDefaults.locationAuthReminder) as? Bool {
            if showReminder {
                boolean = false
            } else {
                // If the user doesn't want to use location, auto show from field
                // Currently not working, but such an edge case, leaving for now
                self.searchingFrom()
                return
            }
        }
        
        // Most common, realistic error
        let title = "Location Services Disabled"
        let message = "Tap Settings to change your location permissions, or continue using a limited version of the app."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { (_) in
            userDefaults.set(boolean, forKey: Constants.UserDefaults.locationAuthReminder)
        })
        alertController.addAction(UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        })

        present(alertController, animated: true, completion: nil)
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // If haven't selected start location, set to current location
        if searchFrom == nil, let location = manager.location {
            currentLocation = location.coordinate
            let currentLocationStop = BusStop(name: Constants.Stops.currentLocation,
                                               lat: location.coordinate.latitude,
                                               long: location.coordinate.longitude)
            searchFrom = currentLocationStop
            searchBarView.resultsViewController?.currentLocation = currentLocationStop
            routeSelection.fromSearchbar.setTitle(currentLocationStop.name, for: .normal)
            searchForRoutes()
        }
    }

    // MARK: Datepicker

    private func setupDatepicker() {
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
        if routeSelection.datepickerButton.titleLabel?.text?.lowercased() == "leave now" {
            datePickerView.setDatepickerDate(date: Date())
        }
        else if let time = searchTime {
            datePickerView.setDatepickerDate(date: time)
        }

        datePickerView.setDatepickerTimeType(searchTimeType: searchTimeType)

        UIView.animate(withDuration: 0.5) {
            self.datePickerView.center.y = self.view.frame.height - (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.6 // darken screen when pull up datepicker
        }
        
        let payload = DatePickerAccessedPayload()
        RegisterSession.shared?.logEvent(event: payload.toEvent())
        
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
        let dateString = Time.dateString(from: date)
        let segmentedControl = datePickerView.timeTypeSegmentedControl

        // Get selected time type
        let selectedSegString = (segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)) ?? ""
        if selectedSegString.lowercased().contains("arrive") {
            searchTimeType = .arriveBy
        }else{
            searchTimeType = .leaveAt
        }

        // Customize string based on date
        var title = ""
        if Calendar.current.isDateInToday(date) || Calendar.current.isDateInTomorrow(date) {
            let verb = (searchTimeType == .arriveBy) ? "Arrive" : "Leave" //Use simply,"arrive" or "leave"
            let day = Calendar.current.isDateInToday(date) ? "" : " tomorrow" //if today don't put day
            title = "\(verb)\(day) at \(Time.timeString(from: date))"
        }else{
            let verb = (searchTimeType == .arriveBy) ? "Arrive by" : "Leave on" //Use "arrive by" or "leave on"
            title = "\(verb) \(dateString)"
        }
        routeSelection.datepickerButton.setTitle(title, for: .normal)

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
        
        var cell = tableView.dequeueReusableCell(withIdentifier: routeTableViewCellIdentifier, for: indexPath) as? RouteTableViewCell

        if cell == nil {
            cell = RouteTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: routeTableViewCellIdentifier)
        }

        cell?.setData(routes[indexPath.row])
        cell?.positionSubviews()
        cell?.addSubviews()

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
            print("RouteOptionsVC setupReachability: Could not start reachability notifier")
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

        if currentlySearching {
            symbolView = LoadingIndicator()
        }  else {
            let imageView = UIImageView(image: #imageLiteral(resourceName: "road"))
            imageView.contentMode = .scaleAspectFit
            symbolView = imageView
        }

        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14.0)
        titleLabel.textColor = .mediumGrayColor
        titleLabel.text = currentlySearching ? "Looking for routes..." : "No Routes Found"
        titleLabel.sizeToFit()

        customView.addSubview(symbolView)
        customView.addSubview(titleLabel)

        symbolView.snp.makeConstraints{ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(currentlySearching ? -20 : -22.5)
            make.width.equalTo(currentlySearching ? 40 : 45)
            make.height.equalTo(currentlySearching ? 40 : 45)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(symbolView.snp.bottom).offset(10)
            make.centerX.equalTo(symbolView.snp.centerX)
        }

        return customView
    }

    // MARK: Tableview Delegate

    private func setupRouteResultsTableView() {
        
        routeResults = UITableView(frame: CGRect(x: 0, y: routeSelection.frame.maxY, width: view.frame.width, height: view.frame.height - routeSelection.frame.height - (navigationController?.navigationBar.frame.height ?? 0)), style: .grouped)
        routeResults.delegate = self
        routeResults.allowsSelection = true
        routeResults.dataSource = self
        routeResults.separatorStyle = .none
        routeResults.backgroundColor = .tableBackgroundColor
        routeResults.alwaysBounceVertical = true //so table view doesn't scroll over top & bottom
        routeResults.showsVerticalScrollIndicator = false

        refreshControl.isHidden = true

        if #available(iOS 10.0, *) {
            routeResults.refreshControl = refreshControl
        } else {
            routeResults.addSubview(refreshControl)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let directions = routes[indexPath.row].directions
        let isWalkingRoute = routes[indexPath.row].isWalkingRoute()

        // if walking route, don't skip first walking direction. Ow skip first walking direction
        let numOfStops = isWalkingRoute ? directions.count : (directions.first?.type == .walk ? directions.count - 1 : directions.count)
        let rowHeight = RouteTableViewCell().heightForCell(withNumOfStops: numOfStops, withNumOfWalkLines: routes[indexPath.row].getNumOfWalkLines())

        return rowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        locationManager.stopUpdatingLocation()
        if let routeDetailViewController = createRouteDetailViewController(from: routes[indexPath.row]) {
            let payload = RouteResultsCellTappedEventPayload()
            RegisterSession.shared?.logEvent(event: payload.toEvent())
            navigationController?.pushViewController(routeDetailViewController, animated: true)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
            searchForRoutes()
        }
    }
    
    // Create RouteDetailViewController
    
    func createRouteDetailViewController(from route: Route) -> RouteDetailViewController? {
        let contentViewController = RouteDetailContentViewController(route: route, currentLocation: currentLocation)
        guard let drawerViewController = contentViewController.drawerDisplayController else {
            return nil
        }
        return RouteDetailViewController(contentViewController: contentViewController,
                                         drawerViewController: drawerViewController)
    }
    
}

extension RouteOptionsViewController: UIViewControllerPreviewingDelegate {
    
    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: routeResults)
            if let indexPath = routeResults.indexPathForRow(at: point) {
                presentShareSheet(for: routes[indexPath.row])
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
        
        routeDetailViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        routeDetailViewController.isPeeking = true
        cell.transform = .identity
        previewingContext.sourceRect = routeResults.convert(cell.frame, to: view)
        
        let payload = RouteResultsCellPeekedPayload()
        RegisterSession.shared?.logEvent(event: payload.toEvent())
        
        return routeDetailViewController
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        (viewControllerToCommit as? RouteDetailViewController)?.isPeeking = false
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}
