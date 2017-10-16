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

enum SearchBarType: String{
    case from, to
}

enum SearchType: String{
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
    var datePickerView: DatepickerView!
    var datePickerOverlay: UIView!
    var routeResults: UITableView!

    let navigationBarTitle: String = "Route Options"
    let routeTableViewCellIdentifier: String = RouteTableViewCell().identifier
    let routeResultsTitle: String = "Route Results"
    let routeResultsHeaderHeight: CGFloat = 57.0

    // MARK:  Data vars

    var routes: [Route] = []
    var loaderroutes: [Route] = []

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .tableBackgroundColor

        setupNavigationBar()
        setupBackButton()

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

//        setupLoaderData()
//        routes = loaderroutes

        // If no date is set then date should be same as today's date
        self.searchTime = Date()

        searchForRoutes()
    }

    override func viewWillAppear(_ animated: Bool) {
        routeResults.register(RouteTableViewCell.self, forCellReuseIdentifier: routeTableViewCellIdentifier)
    }

    // MARK: Navigation bar

    private func setupNavigationBar(){
        let titleAttributes: [String : Any] = [NSFontAttributeName : UIFont(name :".SFUIText", size: 18)!,
                                               NSForegroundColorAttributeName : UIColor.black]
        title = navigationBarTitle
        navigationController?.navigationBar.titleTextAttributes = titleAttributes //so title actually shows up
    }

    private func setupBackButton(){
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        let attributedString = NSMutableAttributedString(string: "  Back")
        // raise back button text a hair - attention to detail, baby
        attributedString.addAttribute(NSBaselineOffsetAttributeName, value: 0.3, range: NSMakeRange(0, attributedString.length))
        backButton.setAttributedTitle(attributedString, for: .normal)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        let barButtonBackItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.setLeftBarButton(barButtonBackItem, animated: true)
    }

    // Move back one view controller in navigationController stack
    func backAction() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: Loader

    private func setupLoaderData(){
        let date1 = Time.date(fromTime: "3:45 PM")
        let date2 = Time.date(fromTime: "3:52 PM")
        let routeObject1 = RouteSummaryObject(name: "Baker Flagpole", type: .stop, nextDirection: .bus, busNumber: 90)
        let routeObject2 = RouteSummaryObject(name: "Commons - Seneca Street", type: .stop)
        let routeSummary1 = [routeObject1, routeObject2]

        let route1 = Route(departureTime: date1, arrivalTime: date2, startCoords: CLLocation().coordinate,
                           endCoords: CLLocation().coordinate, directions: [], routeSummary: routeSummary1)

        let date3 = Time.date(fromTime: "3:45 PM")
        let date4 = Time.date(fromTime: "3:52 PM")
        let routeObject3 = RouteSummaryObject(name: "Baker Flagpole", type: .stop, nextDirection: .bus, busNumber: 8)
        let routeObject4 = RouteSummaryObject(name: "Collegetown Crossing", type: .stop, nextDirection: .bus, busNumber: 16)
        let routeObject5 = RouteSummaryObject(name: "Commons - Seneca Street", type: .stop, nextDirection: .walk)
        let routeObject10 = RouteSummaryObject(name: "Waffle Frolic", type: .place)
        let routeSummary2 = [routeObject3, routeObject4, routeObject5, routeObject10]
        let route2 = Route(departureTime: date3, arrivalTime: date4, startCoords: CLLocation().coordinate,
                           endCoords: CLLocation().coordinate, directions: [], routeSummary: routeSummary2)

        let date5 = Time.date(fromTime: "3:45 PM")
        let date6 = Time.date(fromTime: "3:52 PM")
        let routeObject6 = RouteSummaryObject(name: "Baker Flagpole", type: .stop, nextDirection: .bus, busNumber: 8)
        let routeObject7 = RouteSummaryObject(name: "Jessup Fields", type: .stop, nextDirection: .walk)
        let routeObject8 = RouteSummaryObject(name: "RPCC", type: .stop, nextDirection: .bus, busNumber: 32)
        let routeObject9 = RouteSummaryObject(name: "Commons - Seneca Street", type: .stop)
        let routeSummary3 = [routeObject6, routeObject7, routeObject8, routeObject9]
        let route3 = Route(departureTime: date5, arrivalTime: date6, startCoords: CLLocation().coordinate,
                           endCoords: CLLocation().coordinate, directions: [], routeSummary: routeSummary3)

        loaderroutes = [route1, route2, route3]
    }

    // MARK: Route Selection view

    private func setupRouteSelection() {
        routeSelection = RouteSelectionView(frame: CGRect(x: 0, y: -12, width: view.frame.width, height: 150)) // offset for -12 for larger views, get rid of black space
        routeSelection.backgroundColor = .lineColor
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

    func swapFromAndTo(sender: UIButton){
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

    func searchingTo(sender: UIButton){
        searchType = .to
        presentSearchBar()
    }

    func searchingFrom(sender: UIButton){
        searchType = .from
        searchBarView.resultsViewController?.shouldShowCurrentLocation = true
        presentSearchBar()
    }

    func presentSearchBar(){
        var placeholder = ""

        switch searchType {

        case .from:

            if let startingDestinationName = searchFrom?.name {
                placeholder = startingDestinationName
            }
            else {
                placeholder = "Search start locations"
            }

        case .to:

            if let endingDestinationName = searchTo?.name {
                placeholder = endingDestinationName
            }
            else {
                placeholder = "Search destination"
            }

        }

        let textFieldInsideSearchBar = searchBarView.searchController?.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(string: placeholder) //make placeholder invisible

        showSearchBar()
    }

    private func dismissSearchBar(){
        searchBarView.searchController?.dismiss(animated: true, completion: nil)
    }

    func didSelectDestination(busStop: BusStop?, placeResult: PlaceResult?){

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

    func didCancel(){
        hideSearchBar()
    }

    private func hideSearchBar(){
        navigationItem.titleView = nil
        searchBarView.searchController?.isActive = false
    }

    private func showSearchBar(){
        navigationItem.titleView = searchBarView.searchController?.searchBar
        searchBarView.searchController?.isActive = true
    }

    // MARK: Process data

    func searchForRoutes() {
        if let startingDestination = searchFrom as? CoordinateAcceptor, let endingDestination = searchTo as? CoordinateAcceptor{

            routes = []
            currentlySearching = true
            routeResults.reloadData()

//            routes = loaderroutes
//            routeResults.reloadData()
//            Loader.addLoaderTo(routeResults)

            Network.getRoutes(start: startingDestination, end: endingDestination, time: searchTime!, type: searchTimeType) { request in

                request.perform(withSuccess: { (routeJson) in
                    let rawRoutes = Route.getRoutesArray(fromJson: routeJson)
                    self.routes = self.processRoutes(rawRoutes)
                    self.currentlySearching = false
                    self.routeResults.reloadData()
//                    Loader.removeLoaderFrom(self.routeResults)
                },

                failure: { (error) in
                    print("RouteOptionVC searchForRoutes Error: \(error)")
                    self.routes = []
                    self.currentlySearching = false
                    self.routeResults.reloadData()
//                    Loader.removeLoaderFrom(self.routeResults)
                })

            }

        }

    }

    private func processRoutes(_ routes: [Route]) -> [Route]{
        // Update starting & ending place name & pin
        if let startDestination = searchFrom {
            for route in routes {
                route.updateStartingDestination(startDestination)
            }
        }
        if let endDestination = searchTo {
            for route in routes{
                route.updateEndingDestination(endDestination)
            }
        }
        
        // Add directions array
        for route in routes {
            route.addWalkingDirections()
        }

        return routes
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

        let title = "Couldn't Find Current Location"
        let message = "Please ensure you are connected to the internet and have enabled location permissions."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        let settings = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }

        alertController.addAction(settings)

        present(alertController, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // If haven't selected start location, set to current location
        if searchFrom == nil, let location = manager.location {
            let currentLocationStop =  BusStop(name: "Current Location", lat: location.coordinate.latitude, long: location.coordinate.longitude)
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
        datePickerView = DatepickerView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 305.5))
        datePickerView.positionSubviews()
        datePickerView.addSubviews()
        datePickerView.backgroundColor = .white

        datePickerView.cancelButton.addTarget(self, action: #selector(self.dismissDatepicker), for: .touchUpInside)
        datePickerView.doneButton.addTarget(self, action: #selector(self.saveDatepickerDate), for: .touchUpInside)
    }

    private func setupDatepickerOverlay(){
        datePickerOverlay = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        datePickerOverlay.backgroundColor = .black
        datePickerOverlay.alpha = 0

        datePickerOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissDatepicker)))
    }

    func showDatepicker(sender: UIButton){
        view.bringSubview(toFront: datePickerOverlay)
        view.bringSubview(toFront: datePickerView)
        UIView.animate(withDuration: 0.5) {
            self.datePickerView.center.y = self.view.frame.height - (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.7
        }
    }

    func dismissDatepicker(sender: UIButton){
        UIView.animate(withDuration: 0.5, animations: {
            self.datePickerView.center.y = self.view.frame.height + (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.0
        }) { (completion) in
            self.view.sendSubview(toBack: self.datePickerOverlay)
            self.view.sendSubview(toBack: self.datePickerView)
        }
    }

    func saveDatepickerDate(sender: UIButton){
        let date = datePickerView.datepicker.date
        searchTime = date
        let dateString = Time.dateString(from: date)
        let segmentedControl = datePickerView.segmentedControl

        // Get selected time type
        let selectedSegString = (segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)) ?? ""
        if (selectedSegString.lowercased().contains("arrive")){
            searchTimeType = .arriveBy
        }else{
            searchTimeType = .leaveAt
        }

        // Customize string based on date
        var title = ""
        if(Calendar.current.isDateInToday(date) || Calendar.current.isDateInTomorrow(date)){
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

        cell?.route = routes[indexPath.row]
        cell?.setRouteData()
        cell?.positionSubviews()
        cell?.addSubviews()

        return cell!
    }

    // MARK: DZNEmptyDataSet

    private func setupEmptyDataSet() {
        routeResults.emptyDataSetSource = self
        routeResults.emptyDataSetDelegate = self
        routeResults.tableFooterView = UIView()
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let message = currentlySearching ? "Looking for routes..." : "No Routes Found"
        let attrs: [String : Any] = [
            NSFontAttributeName : UIFont(name: FontNames.SanFrancisco.Regular, size: 14.0)!,
            NSForegroundColorAttributeName : UIColor.mediumGrayColor
        ]

        return NSAttributedString(string: message, attributes: attrs)
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return currentlySearching ? #imageLiteral(resourceName: "reload") : #imageLiteral(resourceName: "road")
    }

    // MARK: Tableview Delegate

    private func setupRouteResultsTableView(){
        routeResults = UITableView(frame: CGRect(x: 0, y: routeSelection.frame.maxY, width: view.frame.width, height: view.frame.height - routeSelection.frame.height - (navigationController?.navigationBar.frame.height ?? 0)), style: .grouped)
        routeResults.delegate = self
        routeResults.allowsSelection = true
        routeResults.dataSource = self
        routeResults.separatorStyle = .none
        routeResults.backgroundColor = .tableBackgroundColor
        routeResults.alwaysBounceVertical = false //so table view doesn't scroll over top & bottom
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
        let numOfStops = routes[indexPath.row].routeSummary.count
        let rowHeight = RouteTableViewCell().heightForCell(withNumOfStops: numOfStops)

        return rowHeight
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool{
        navigationController?.pushViewController(RouteDetailViewController(route: routes[indexPath.row]), animated: true)

        return false // halts the selection process, so don't have selected look
    }

}
