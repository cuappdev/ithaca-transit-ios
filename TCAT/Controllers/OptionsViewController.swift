//
//  OptionsViewController.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

/* 2Bringup:
 * Don't think should limit the search of past or future bus routes (just for that edge case. Also GoogleMaps doesn't do that)
 * 2Do:
 * work on overflow - datepicker & dist label (maybe put below)
 * "Sorry no routes" or blank if don't fill in all fields screen
 * Rename search bar vars? VC? RouteSelectionView? (kind of unclear)
 * Bugs:
 * Distance is still 0.0
 */
enum SearchBarType: String{
    case from, to
}

enum SearchType: String{
    case arriveBy, leaveAt
}

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    DestinationDelegate, SearchBarCancelDelegate,UISearchBarDelegate,
CLLocationManagerDelegate {

    // MARK: Search bar vars

    var searchBarView: SearchBarView!
    var locationManager: CLLocationManager!
    var searchType: SearchBarType = .from
    var searchFrom: (BusStop?, PlaceResult?) = (nil, nil)
    var searchTo: (BusStop?, PlaceResult?) = (nil, nil)
    var searchTimeType: SearchType = .leaveAt
    var searchTime: Date?

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

        view.addSubview(routeSelection)
        view.addSubview(datePickerOverlay)
        view.sendSubview(toBack: datePickerOverlay)
        view.addSubview(routeResults)
        view.addSubview(datePickerView)//so datePicker can go ontop of other views

        setRouteSelectionView(withDestination: searchTo)
        setupLocationManager()

        setupLoaderData()
        routes = loaderroutes

        // If no date is set then date should be same as today's date
        self.searchTime = Date()

        //        searchForRoutes()
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
        let date1 = Time.dateForDebug(from: "3:45 PM")
        let date2 = Time.dateForDebug(from: "3:52 PM")
        let routeObject1 = RouteSummaryObject(name: "Baker Flagpole", type: .stop, nextDirection: .bus, busNumber: 90)
        let routeObject2 = RouteSummaryObject(name: "Commons - Seneca Street", type: .stop)
        let routeSummary1 = [routeObject1, routeObject2]

        let route1 = Route(departureTime: date1, arrivalTime: date2, routeSummary: routeSummary1, directions: [], path: [], travelDistance: 0.1)

        let date3 = Time.dateForDebug(from: "3:45 PM")
        let date4 = Time.dateForDebug(from: "3:52 PM")
        let routeObject3 = RouteSummaryObject(name: "Baker Flagpole", type: .stop, nextDirection: .bus, busNumber: 8)
        let routeObject4 = RouteSummaryObject(name: "Collegetown Crossing", type: .stop, nextDirection: .bus, busNumber: 16)
        let routeObject5 = RouteSummaryObject(name: "Commons - Seneca Street", type: .stop, nextDirection: .walk)
        let routeObject10 = RouteSummaryObject(name: "Waffle Frolic", type: .place)
        let routeSummary2 = [routeObject3, routeObject4, routeObject5, routeObject10]
        let route2 = Route(departureTime: date3, arrivalTime: date4, routeSummary: routeSummary2, directions: [], path: [], travelDistance: 0.1)

        let date5 = Time.dateForDebug(from: "3:45 PM")
        let date6 = Time.dateForDebug(from: "3:52 PM")
        let routeObject6 = RouteSummaryObject(name: "Baker Flagpole", type: .stop, nextDirection: .bus, busNumber: 8)
        let routeObject7 = RouteSummaryObject(name: "Jessup Fields", type: .stop, nextDirection: .walk)
        let routeObject8 = RouteSummaryObject(name: "RPCC", type: .stop, nextDirection: .bus, busNumber: 32)
        let routeObject9 = RouteSummaryObject(name: "Commons - Seneca Street", type: .stop)
        let routeSummary3 = [routeObject6, routeObject7, routeObject8, routeObject9]
        let route3 = Route(departureTime: date5, arrivalTime: date6, routeSummary: routeSummary3, directions: [], path: [], travelDistance: 0.1)

        loaderroutes = [route1, route2, route3]
    }

    // MARK: Route Selection view

    private func setupRouteSelection() {
        routeSelection = RouteSelectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 150))
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

    private func setRouteSelectionView(withDestination destination: (BusStop?, PlaceResult?)){
        let (endBus, endPlace) = destination
        if let destination = endBus{
            routeSelection.toSearchbar.setTitle(destination.name, for: .normal)
        }
        if let destination = endPlace{
            routeSelection.toSearchbar.setTitle(destination.name, for: .normal)
        }
    }

    func swapFromAndTo(sender: UIButton){
        //Swap data
        let searchFromOld = searchFrom
        searchFrom = searchTo
        searchTo = searchFromOld

        //Update UI
        let (fromBus, fromPlace) = searchFrom
        let (toBus, toPlace) = searchTo

        if let start = fromBus {
            routeSelection.fromSearchbar.setTitle(start.name, for: .normal)
        }else if let start = fromPlace {
            routeSelection.fromSearchbar.setTitle(start.name, for: .normal)
        }else{
            routeSelection.fromSearchbar.setTitle("", for: .normal)
        }

        if let end = toBus {
            routeSelection.toSearchbar.setTitle(end.name, for: .normal)
        }else if let end = toPlace {
            routeSelection.toSearchbar.setTitle(end.name, for: .normal)
        }else{
            routeSelection.toSearchbar.setTitle("", for: .normal)
        }

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
        //For Austin's search bar to show current location option or not
        //        searchBarView.resultsViewController.shouldShowCurrentLocation = false
        presentSearchBar()
    }

    func searchingFrom(sender: UIButton){
        searchType = .from
        //For Austin's search bar to show current location option or not
        //        searchBarView.resultsViewController.shouldShowCurrentLocation = false
        presentSearchBar()
    }

    func presentSearchBar(){
        showSearchBar()
        //Customize placeholder
        let placeholder = (searchType == .from) ? "Search start locations" : "Search destination"
        let textFieldInsideSearchBar = searchBarView.searchController?.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(string: placeholder) //make placeholder invisible
        //Prompt search
        //searchBarView.searchController?.searchBar.text = (searchType == .from) ? routeSelection.fromSearch.titleLabel?.text : routeSelection.toSearch.titleLabel?.text
    }

    private func dismissSearchBar(){
        searchBarView.searchController?.dismiss(animated: true, completion: nil)
    }

    func didSelectDestination(busStop: BusStop?, placeResult: PlaceResult?){
        switch searchType{
        case .from:
            if let result = busStop{
                searchFrom = (result, nil)
                routeSelection.fromSearchbar.setTitle(result.name, for: .normal)
            }else if let result = placeResult{
                searchFrom = (nil, result)
                routeSelection.fromSearchbar.setTitle(result.name, for: .normal)                }
        default:
            if let result = busStop{
                searchTo = (result, nil)
                routeSelection.toSearchbar.setTitle(result.name, for: .normal)
            }else if let result = placeResult{
                searchTo = (nil, result)
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

    func searchForRoutes() {

        let (startingDestination, endingDestination) = getSearchTuple(startingDestinationTuple: searchFrom, endingDestinationTuple: searchTo)

        if let startingDestination = startingDestination, let endingDestination = endingDestination{
            routes = loaderroutes
            routeResults.reloadData()
            Loader.addLoaderTo(routeResults)
            Network.getRoutes(start: startingDestination, end: endingDestination, time: searchTime!, type: searchTimeType) { request in
                print(request.parameters)
                request.perform(withSuccess: { (routes) in
                    print("GOT ROUTES", routes)
                    self.routes = routes
                    self.routeResults.reloadData()
                    Loader.removeLoaderFrom(self.routeResults)
                }, failure: { (error) in
                    print("OptionVC SearchForRoutes Error: \(error)")
                    self.routes = []
                    self.routeResults.reloadData()
                    Loader.removeLoaderFrom(self.routeResults)
                })
            }
        }
    }

    private func getSearchTuple(startingDestinationTuple: (BusStop?, PlaceResult?), endingDestinationTuple: (BusStop?, PlaceResult?)) -> (startingDestination: AnyObject?, endingDestination: AnyObject?){

        let (fromBus, fromPlace) = searchFrom
        let (toBus, toPlace) = searchTo

        if let startBus = fromBus, let endBus = toBus{
            return (startBus, endBus)
        }

        if let startBus = fromBus, let endPlace = toPlace{
            return (startBus, endPlace)
        }

        if let startPlace = fromPlace, let endBus = toBus{
            return (startPlace, endBus)
        }

        if let startPlace = fromPlace, let endPlace = toPlace{
            return (startPlace, endPlace)
        }

        return (nil, nil)

    }

    // MARK: Location Manager Delegate

    private func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        // locationManager.requestLocation() // one-time call
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        locationManager.stopUpdatingLocation()
        print("OptionVC locationManager didFailWithError: \(error.localizedDescription)")

        let title = "Couldn't Find Location"
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
        //If don't have start location, set to current location
        locationManager.stopUpdatingLocation()
        if searchFrom.0 == nil, let location = manager.location {
            let currentLocationStop =  BusStop(name: "Current Location", lat: location.coordinate.latitude, long: location.coordinate.longitude)
            searchFrom.0 = currentLocationStop
            searchBarView.resultsViewController?.currentLocation = currentLocationStop
            routeSelection.fromSearchbar.setTitle(searchFrom.0?.name, for: .normal)
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
        }) { (true) in
            self.view.sendSubview(toBack: self.datePickerOverlay)
            self.view.sendSubview(toBack: self.datePickerView)
        }
    }

    func saveDatepickerDate(sender: UIButton){
        let date = datePickerView.datepicker.date
        searchTime = date
        let dateString = Time.fullString(from: date)
        let segmentedControl = datePickerView.segmentedControl
        let selectedSegString = (segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)) ?? ""
        if (selectedSegString.lowercased().contains("arrive")){
            searchTimeType = .arriveBy
        }else{
            searchTimeType = .leaveAt
        }
        var title = ""
        //Customize string based on date
        if(Calendar.current.isDateInToday(date) || Calendar.current.isDateInTomorrow(date)){
            let verb = (searchTimeType == .arriveBy) ? "Arrive" : "Leave" //Use simply,"arrive" or "leave"
            let day = Calendar.current.isDateInToday(date) ? "" : " tomorrow" //if today don't put day
            title = "\(verb)\(day) at \(Time.string(from: date))"
        }else{
            let verb = (searchTimeType == .arriveBy) ? "Arrive by" : "Leave on" //Use "arrive by" or "leave on"
            title = "\(verb) \(dateString)"
        }
        routeSelection.datepickerButton.setTitle(title, for: .normal)

        dismissDatepicker(sender: sender)

        searchForRoutes()
    }

    //MARK: Tableview Data Source

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

    // MARK: Tableview Delegate

    private func setupRouteResultsTableView(){
        routeResults = UITableView(frame: CGRect(x: 0, y: routeSelection.frame.maxY, width: view.frame.width, height: view.frame.height - routeSelection.frame.height - (navigationController?.navigationBar.frame.height ?? 0) - UIApplication.shared.statusBarFrame.height), style: .grouped)
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
        titleLabel.font = UIFont(name: "SFUIText-Regular", size: 14.0)
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
        navigationController?.pushViewController(RouteDetailViewController(route: nil), animated: true) // routes[indexPath.row]
        return false // halts the selection process = don't have selected look
    }

}
