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

    var banner: StatusBarNotificationBanner = {
        let banner = StatusBarNotificationBanner(title: "No internet connection. Retrying...", style: .danger)
        banner.autoDismiss = false
        return banner
    }()

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
    }

    override func viewWillAppear(_ animated: Bool) {
        routeResults.register(RouteTableViewCell.self, forCellReuseIdentifier: routeTableViewCellIdentifier)
        setupReachability()
    }

    override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 11, *) {
            addHeightToDatepicker(20)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        takedownReachability()
    }

    // MARK: Route Selection view

    private func setupRouteSelection() {
        routeSelection = RouteSelectionView(frame: CGRect(x: 0, y: -12, width: view.frame.width, height: 150)) // offset for -12 for larger views, get rid of black space
        routeSelection.backgroundColor = .white
        routeSelection.positionSubviews()
        routeSelection.addSubviews()
        var newRSFrame = routeSelection.frame
        newRSFrame.size.height =  routeSelection.lineWidth + routeSelection.searcbarView.frame.height + routeSelection.lineWidth + routeSelection.datepickerButton.frame.height
        routeSelection.frame = newRSFrame

        routeSelection.toSearchbar.addTarget(self, action: #selector(self.searchingTo), for: .touchUpInside)
        routeSelection.fromSearchbar.addTarget(self, action: #selector(self.searchingFrom), for: .touchUpInside)
        routeSelection.datepickerButton.addTarget(self, action: #selector(self.showDatepicker), for: .touchUpInside)
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

    private func setupSearchBar(){
        searchBarView = SearchBarView()
        searchBarView.resultsViewController?.destinationDelegate = self
        searchBarView.resultsViewController?.searchBarCancelDelegate = self
        searchBarView.searchController?.searchBar.sizeToFit()
        self.definesPresentationContext = true
        hideSearchBar()
    }

    @objc func searchingTo(sender: UIButton){
        searchType = .to
        presentSearchBar()
    }

    @objc func searchingFrom(sender: UIButton){
        searchType = .from
        searchBarView.resultsViewController?.shouldShowCurrentLocation = true
        presentSearchBar()
    }

    func presentSearchBar(){
        var placeholder = ""
        var searchBarText = ""

        switch searchType {

        case .from:

            if let startingDestinationName = searchFrom?.name {
                if startingDestinationName != Key.Stops.currentLocation {
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

    private func dismissSearchBar(){
        searchBarView.searchController?.dismiss(animated: true, completion: nil)
    }

    func didSelectDestination(busStop: BusStop?, placeResult: PlaceResult?) {

        switch searchType{

        case .from:

            if let result = busStop{
                searchFrom = result
                routeSelection.fromSearchbar.setTitle(result.name, for: .normal)
            }else if let result = placeResult{
                searchFrom = result
                routeSelection.fromSearchbar.setTitle(result.name, for: .normal)
            }

        case .to:

            if let result = busStop{
                searchTo = result
                routeSelection.toSearchbar.setTitle(result.name, for: .normal)
            }else if let result = placeResult{
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

        if let time = searchTime, let startingDestination = searchFrom as? CoordinateAcceptor, let endingDestination = searchTo as? CoordinateAcceptor{

            routes = []
            currentlySearching = true
            routeResults.contentOffset = .zero
            routeResults.reloadData()

            // Check if to and from location is the same
            if searchFrom?.name == searchTo?.name {

                let title = "You're here!"
                let message = "You have arrived at your destination. Thank you for using our TCAT Teleporation™ feature (beta)."
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "😐😒🙄", style: .cancel, handler: nil)
                alertController.addAction(action)
                present(alertController, animated: true, completion: nil)

                currentlySearching = false
                routeResults.reloadData()

            }

            else {

            Network.getRoutes(start: startingDestination, end: endingDestination, time: time, type: searchTimeType) { request in

                if #available(iOS 10.0, *) {
                    self.routeResults.refreshControl?.endRefreshing()
                } else {
                    self.refreshControl.endRefreshing()
                }

                func requestDidFinish(with error: NSError? = nil) {
                    if let err = error {
                        print("RouteOptionVC searchForRoutes Error: \(err)")
                        // print("Error Description:", err.userInfo["description"] as? String)
                        self.banner = StatusBarNotificationBanner(title: "Could not connect to server", style: .danger)
                        self.banner.autoDismiss = false
                        self.banner.show(queuePosition: .front, on: self)
                        self.isBannerShown = true
                        UIApplication.shared.statusBarStyle = .lightContent
                    }
                    self.currentlySearching = false
                    self.routeResults.reloadData()
                }

                if let alamofireRequest = request?.perform(
                    withSuccess: { (routeJSON) in
                        Route.getRoutes(in: routeJSON, from: self.searchFrom?.name, to: self.searchTo?.name,
                        { (parsedRoutes,error) in
                            self.routes = parsedRoutes
                            requestDidFinish(with: error)
                        })
                    },
                    failure: { (error) in
                        print("Request Failure:", error)
                        self.routes = []
                        requestDidFinish(with: error as NSError)
                    })
                { // Handle non-null request
                    let event = DestinationSearchedEventPayload(destination: self.searchTo?.name ?? "",
                                                                requestUrl: alamofireRequest.request?.url?.absoluteString,
                                                                stopType: nil).toEvent()
                    let _ = RegisterSession.shared?.logEvent(event: event)
                }

                else { // Catch error of coordinates not being found
                    let error = NSError(domain: "Null Coordinates", code: 400, userInfo: nil)
                    requestDidFinish(with: error)
                }

            }

            }

        }

    }

    // MARK: Location Manager Delegate

    private func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        locationManager.stopUpdatingLocation()
        print("RouteOptionVC locationManager didFailWithError: \(error.localizedDescription)")

        let title = "Couldn't Find \(Key.Stops.currentLocation)"
        let message = "Please ensure you are connected to the internet and have enabled location permissions."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        let settings = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }

        alertController.addAction(settings)

        present(alertController, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // If haven't selected start location, set to current location
        if searchFrom == nil, let location = manager.location {
            let currentLocationStop =  BusStop(name: Key.Stops.currentLocation, lat: location.coordinate.latitude, long: location.coordinate.longitude)
            searchFrom = currentLocationStop
            searchBarView.resultsViewController?.currentLocation = currentLocationStop
            routeSelection.fromSearchbar.setTitle(currentLocationStop.name, for: .normal)
            searchForRoutes()
        }
    }

    // MARK: Datepicker

    private func setupDatepicker(){
        setupDatepickerView()
        setupDatepickerOverlay()
    }

    private func setupDatepickerView(){
        datePickerView = DatePickerView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 254))

        datePickerView.positionSubviews()
        datePickerView.addSubviews()

        datePickerView.cancelButton.addTarget(self, action: #selector(self.dismissDatepicker), for: .touchUpInside)
        datePickerView.doneButton.addTarget(self, action: #selector(self.saveDatepickerDate), for: .touchUpInside)
    }

    private func setupDatepickerOverlay(){
        datePickerOverlay = UIView(frame: CGRect(x: 0, y: -12, width: view.frame.width, height: view.frame.height + 12)) // 12 for sliver that shows up when click datepicker immediately after transition from HomeVC
        datePickerOverlay.backgroundColor = .black
        datePickerOverlay.alpha = 0

        datePickerOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissDatepicker)))
    }

    private func addHeightToDatepicker(_ height: CGFloat) {
        let oldFrame = datePickerView.frame
        let newFrame = CGRect(x: oldFrame.minX, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height + height)

        datePickerView.frame = newFrame
    }

    @objc func showDatepicker(sender: UIButton){
        view.bringSubview(toFront: datePickerOverlay)
        view.bringSubview(toFront: datePickerView)

        // set up date on datepicker view
        if routeSelection.datepickerButton.titleLabel?.text?.lowercased() == "leave now" {
            datePickerView.setDatepickerDate(date: Date())
        }
        else if let time = searchTime  {
            datePickerView.setDatepickerDate(date: time)
        }

        datePickerView.setDatepickerTimeType(searchTimeType: searchTimeType)

        UIView.animate(withDuration: 0.5) {
            self.datePickerView.center.y = self.view.frame.height - (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.6 // darken screen when pull up datepicker
        }
    }

    @objc func dismissDatepicker(sender: UIButton){
        UIView.animate(withDuration: 0.5, animations: {
            self.datePickerView.center.y = self.view.frame.height + (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.0
        }) { (completion) in
            self.view.sendSubview(toBack: self.datePickerOverlay)
            self.view.sendSubview(toBack: self.datePickerView)
        }
    }

    @objc func saveDatepickerDate(sender: UIButton){
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

        dismissDatepicker(sender: sender)

        searchForRoutes()
    }

    // MARK: Tableview Data Source

    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return routeResultsTitle
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return routes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCell(withIdentifier: routeTableViewCellIdentifier, for: indexPath) as? RouteTableViewCell

        if cell == nil {
            cell = RouteTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: routeTableViewCellIdentifier)
        }

        cell?.setData(routes[indexPath.row])
        cell?.positionSubviews()
        cell?.addSubviews()

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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isBannerShown ? .lightContent : .default
    }

    @objc private func reachabilityChanged(_ notification: Notification) {

        let reachability = notification.object as! Reachability

        switch reachability.connection {

            case .none:
                banner.show(queuePosition: .front, bannerPosition: .top, on: self.navigationController)
                isBannerShown = true
                setUserInteraction(to: false)

            case .cellular, .wifi:
                if isBannerShown {
                    banner.dismiss()
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
        cell?.selectionStyle = userInteraction ? .default : .none
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
        }
        else {
            let imageView = UIImageView(image: #imageLiteral(resourceName: "road"))
            imageView.contentMode = .scaleAspectFit

            symbolView = imageView
        }

        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14.0)
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

    private func setupRouteResultsTableView(){
        routeResults = UITableView(frame: CGRect(x: 0, y: routeSelection.frame.maxY, width: view.frame.width, height: view.frame.height - routeSelection.frame.height - (navigationController?.navigationBar.frame.height ?? 0)), style: .grouped)
        routeResults.delegate = self
        routeResults.allowsSelection = true
        routeResults.dataSource = self
        routeResults.separatorStyle = .none
        routeResults.backgroundColor = .tableBackgroundColor
        routeResults.alwaysBounceVertical = true //so table view doesn't scroll over top & bottom

        refreshControl.isHidden = true

        if #available(iOS 10.0, *) {
            routeResults.refreshControl = refreshControl
        } else {
            routeResults.addSubview(refreshControl)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return routeResultsHeaderHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: routeResultsHeaderHeight))
        headerView.backgroundColor = .tableBackgroundColor

        let titleLeftSpaceFromSuperview: CGFloat = 16.0
        let titleVeticalSpaceFromSuperview: CGFloat = 24.0

        let titleLabel = UILabel(frame: CGRect(x: titleLeftSpaceFromSuperview, y: titleVeticalSpaceFromSuperview, width: 88.0, height: 17.0))
        titleLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14.0)
        titleLabel.textColor = UIColor.secondaryTextColor
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        titleLabel.sizeToFit()

        headerView.addSubview(titleLabel)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let directions = routes[indexPath.row].directions
        let isWalkingRoute = routes[indexPath.row].isWalkingRoute()

        // if walking route, don't skip first walking direction. Ow skip first walking direction
        let numOfStops = isWalkingRoute ? directions.count : (directions.first?.type == .walk ? directions.count - 1 : directions.count)
        let rowHeight = RouteTableViewCell().heightForCell(withNumOfStops: numOfStops)

        return rowHeight
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        locationManager.stopUpdatingLocation()
        let contentViewController = RouteDetailContentViewController(route: routes[indexPath.row])
        guard let drawerViewController = contentViewController.drawerDisplayController else { return false }
        let routeDetailViewController = RouteDetailViewController(contentViewController: contentViewController, drawerViewController: drawerViewController)
        navigationController?.pushViewController(routeDetailViewController, animated: true)
        return false // halts the selection process, so don't have selected look
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
            searchForRoutes()
        }
    }
}
