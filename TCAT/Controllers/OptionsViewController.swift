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

        //If no date is set then date should be same as today's date
        if let _ = searchTime{
        }else{
            self.searchTime = Date()
        }
        
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
        let date1 = Time.date(from: "3:45 PM")
        let date2 = Time.date(from: "3:52 PM")
        let route1 = Route(departureTime: date1, arrivalTime: date2, directions: [], mainStops: ["Baker Flagpole", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
        
        let date3 = Time.date(from: "3:45 PM")
        let date4 = Time.date(from: "3:52 PM")
        let route2 = Route(departureTime: date3, arrivalTime: date4, directions: [], mainStops: ["Baker Flagpole", "Collegetown Crossing", "Commons - Seneca Street"], mainStopsNums: [8, 16, -1], travelDistance: 0.1)
        
        let date5 = Time.date(from: "3:45 PM")
        let date6 = Time.date(from: "3:52 PM")
        let route3 = Route(departureTime: date5, arrivalTime: date6, directions: [], mainStops: ["Baker Flagpole", "Jessup Fields", "RPCC", "Commons - Seneca Street"], mainStopsNums: [8, -2, 32, -1], travelDistance: 0.1)
        
        loaderroutes = [route1, route2, route3]
    }
    
    // MARK: Route Selection view
    
    private func setupRouteSelection(){
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
        
        if let start = fromBus, let name = start.name{
            routeSelection.fromSearchbar.setTitle(name, for: .normal)
        }else if let start = fromPlace, let name = start.name{
            routeSelection.fromSearchbar.setTitle(name, for: .normal)
        }else{
            routeSelection.fromSearchbar.setTitle("", for: .normal)
        }
        
        if let end = toBus, let name = end.name{
            routeSelection.toSearchbar.setTitle(name, for: .normal)
        }else if let end = toPlace, let name = end.name{
            routeSelection.toSearchbar.setTitle(name, for: .normal)
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
    
    func searchForRoutes(){
        if searchTime == nil && routeSelection.datepickerButton.titleLabel?.text?.lowercased() == "leave now"{
            searchTime = Date()
        }
        
        let (fromBus, fromPlace) = searchFrom
        let (toBus, toPlace) = searchTo
        if let startBus = fromBus, let endBus = toBus{
            routes = loaderroutes
            routeResults.reloadData()
            Loader.addLoaderTo(routeResults)
            Network.getRoutes(start: startBus, end: endBus, time: searchTime!, type: searchTimeType).perform(withSuccess: { (routes) in
                self.routes = self.getValidRoutes(routes: routes)
                self.routeResults.reloadData()
                Loader.removeLoaderFrom(self.routeResults)
            }, failure: { (error) in
                print("Error: \(error)")
                self.routes = []
                self.routeResults.reloadData()
                Loader.removeLoaderFrom(self.routeResults)
            })
        }
        if let startBus = fromBus, let endPlace = toPlace{
            routes = loaderroutes
            routeResults.reloadData()
            Loader.addLoaderTo(routeResults)
            Network.getRoutes(start: startBus, end: endPlace, time: searchTime!, type: searchTimeType).perform(withSuccess: { (routes) in
                self.routes = self.getValidRoutes(routes: routes)
                self.routeResults.reloadData()
                Loader.removeLoaderFrom(self.routeResults)
            }, failure: { (error) in
                print("Error: \(error)")
                self.routes = []
                self.routeResults.reloadData()
                Loader.removeLoaderFrom(self.routeResults)
            })
        }
        if let startPlace = fromPlace, let endBus = toBus{
            routes = loaderroutes
            routeResults.reloadData()
            Loader.addLoaderTo(routeResults)
            Network.getRoutes(start: startPlace, end: endBus, time: searchTime!, type: searchTimeType).perform(withSuccess: { (routes) in
                self.routes = self.getValidRoutes(routes: routes)
                self.routeResults.reloadData()
                Loader.removeLoaderFrom(self.routeResults)
            }, failure: { (error) in
                print("Error: \(error)")
                self.routes = []
                self.routeResults.reloadData()
                Loader.removeLoaderFrom(self.routeResults)
            })
        }
        if let startPlace = fromPlace, let endPlace = toPlace{
            routes = loaderroutes
            routeResults.reloadData()
            Loader.addLoaderTo(routeResults)
            Network.getRoutes(start: startPlace, end: endPlace, time: searchTime!, type: searchTimeType).perform(withSuccess: { (routes) in
                self.routes = self.getValidRoutes(routes: routes)
                self.routeResults.reloadData()
                Loader.removeLoaderFrom(self.routeResults)
            }, failure: { (error) in
                print("Error: \(error)")
                self.routes = []
                self.routeResults.reloadData()
                Loader.removeLoaderFrom(self.routeResults)
            })
        }
    }
    
    //Leave now = all buses that leave at the user's "now" time
    func getValidRoutes(routes: [Route]) -> [Route]{
        var validroutes: [Route] = []
        for route in routes{
            var validRoute = true
            let directions = route.directions
            //Check directions to invalidate route
            for i in 0..<directions.count{
                if let walkDir = directions[i] as? WalkDirection{
                    if i == 0{
                        walkDir.calculateWalkingDirections({ (distance, walkTimeInterval) in
                            //this might be sketch for leave now, check logic
                            if self.searchTimeType == .leaveAt{ //make sure if walk now to stop, get there before leaveat time
                                let walkToStopDate = Date().addingTimeInterval(walkTimeInterval)
                                if(walkToStopDate > self.searchTime!){
                                    validRoute = false
                                }else{
                                    route.departureTime.addTimeInterval(-walkTimeInterval)
                                    route.directions[i].time = route.departureTime
                                    route.travelDistance = distance
                                    print("travelDistance should be updated with : \(distance)")
                                }
                            }else{ //make sure walk to stop before bus leaves
                                let walkToStopDate = self.searchTime?.addingTimeInterval(walkTimeInterval)
                                if(walkToStopDate! > route.directions[1].time){
                                    validRoute = false
                                }else{
                                    route.departureTime.addTimeInterval(-walkTimeInterval)
                                    route.directions[i].time = route.departureTime
                                }
                            }
                        })
                    }else if i == (directions.count - 1){
                        walkDir.calculateWalkingDirections({ (distance, walkTimeInterval) in
                            if self.searchTimeType == .arriveBy { //make sure walk to destination before arrive by time
                                let walkToDestinationDate = route.directions[i-1].time.addingTimeInterval(walkTimeInterval)
                                if(walkToDestinationDate > self.searchTime!){
                                    validRoute = false
                                }else{
                                    route.arrivalTime.addTimeInterval(walkTimeInterval)
                                    route.directions[i].time = route.arrivalTime
                                }
                            }
                        })
                    }else{ //make sure can walk from previous stop and arrive to next stop by the time bus departs
                        walkDir.calculateWalkingDirections({ (distance, walkTimeInterval) in
                            let walkToStopDate = route.directions[i-1].time.addingTimeInterval(walkTimeInterval)
                            if(walkToStopDate > route.directions[i+1].time){
                                validRoute = false
                            }else{
                                route.directions[i].time = walkToStopDate
                            }
                        })
                    }
                }
            }
            if (validRoute) {
                let (endBus, endPlace) = searchTo
                var lastDir = route.directions.last
                if let busStopDestination = endBus{
                    lastDir?.place = busStopDestination.name!
                }else if let placeDestination = endPlace{
                    lastDir?.place = placeDestination.name!
                    route.addPlaceDestination(placeDestination)
                }
                validroutes.append(route)
            }
        }
        return validroutes
    }

    // MARK: Location Manager Delegate
    
    private func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        locationManager.stopUpdatingLocation()
        print("OptionVC locationManager didFailWithError: \(error)")
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
        let numOfStops = routes[indexPath.row].mainStops.count
        let rowHeight = RouteTableViewCell().heightForCell(withNumOfStops: numOfStops)
        
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool{
        navigationController?.pushViewController(RouteDetailViewController(route: routes[indexPath.row]), animated: true)
        return false // halts the selection process = don't have selected look
    }

}
