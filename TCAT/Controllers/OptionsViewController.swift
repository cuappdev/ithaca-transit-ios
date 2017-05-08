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

/* 2Do:
  * Add Matt's logic
  * deque = the line keeps showing up ??
  * Loader = fix
  * work on overflow - datepicker & dist label (maybe put below)
 */
/* Later:
  * PlaceResult & BuSStop really cannot be 2 different objects, cause too much hassle. N2Do inheritance
  * selection style for cells?
  * Get rid of random print statements
 */
enum SearchBarType: String{
    case from, to
}

enum SearchType: String{
    case arriveby, leaveat
}

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    DestinationDelegate, SearchBarCancelDelegate,UISearchBarDelegate,
    CLLocationManagerDelegate {
    
    //Search bar
    var searchBarView: SearchBarView!
    var locationManager: CLLocationManager!
        //Fill search data w/ default values
    var searchType: SearchBarType = .from //for search bar
    var searchFrom: (BusStop?, PlaceResult?) = (nil, nil)
    var searchTo: (BusStop?, PlaceResult?) = (nil, nil)
    var searchTimeType: SearchType = .leaveat
    var searchTime: Date?
    
    //View
    var routeSelection: RouteSelectionView!
    var datePickerView: DatePickerView!
    var datePickerOverlay: UIView!
    var routeResults: UITableView!
    let identifier: String = "Route cell"
    
    var destinationBusStop: BusStop?
    var destinationPlaceResult: PlaceResult?
    
    //Data
    var routes: [Route] = []
    var loaderroutes: [Route] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up navigation bar
        let titleAttributes: [String : Any] = [NSFontAttributeName : UIFont(name :".SFUIText", size: 18)!,
                                               NSForegroundColorAttributeName : UIColor.black]
        title = "Route Options"
        navigationController?.navigationBar.titleTextAttributes = titleAttributes //so title actually shows up
        
        //Set up route selection view
        routeSelection = RouteSelectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 150))
        routeSelection.backgroundColor = .lineColor
        routeSelection.positionAndAddViews()
        var newRSFrame = routeSelection.frame
        newRSFrame.size.height =  routeSelection.lineWidth + routeSelection.fromToView.frame.height + routeSelection.lineWidth + routeSelection.timeButton.frame.height
        routeSelection.frame = newRSFrame
        view.addSubview(routeSelection)
        
        //Set up search bar for my view
        searchBarView = SearchBarView()
        searchBarView.resultsViewController?.destinationDelegate = self
        searchBarView.resultsViewController?.searchBarCancelDelegate = self
        searchBarView.searchController?.searchBar.sizeToFit()
        self.definesPresentationContext = true
            //Hide search bar
//        navigationItem.titleView = nil
        searchBarView.searchController?.isActive = false
        routeSelection.toSearch.addTarget(self, action: #selector(self.searchingTo), for: .touchUpInside)
        routeSelection.fromSearch.addTarget(self, action: #selector(self.searchingFrom), for: .touchUpInside)
        
        //Autofill destination if user has already selected one from previous screen
        let (endBus, endPlace) = searchTo
        if let destination = endBus{
            routeSelection.toSearch.setTitle(destination.name, for: .normal)
        }
        if let destination = endPlace{
            routeSelection.toSearch.setTitle(destination.name, for: .normal)
        }
        
        //Set up location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        
        //Use users current location if no starting point set
       /* if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse
                || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways {
                locationManager.requestLocation()
            }
            else{
                locationManager.requestWhenInUseAuthorization()
            }
        } */
        
        //Set up datepicker
        routeSelection.timeButton.addTarget(self, action: #selector(self.showDatePicker), for: .touchUpInside)
        datePickerView = DatePickerView(frame: CGRect(x: 0, y: self.view.frame.height, width: view.frame.width, height: 305.5))
        datePickerView.positionAndAddViews()
        datePickerView.backgroundColor = .white
        datePickerView.cancelButton.addTarget(self, action: #selector(self.dismissDatePicker), for: .touchUpInside)
        datePickerView.doneButton.addTarget(self, action: #selector(self.saveDatePickerDate), for: .touchUpInside)
        
        datePickerOverlay = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        datePickerOverlay.backgroundColor = .black
        datePickerOverlay.alpha = 0
        datePickerOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissDatePicker)))
        
        view.addSubview(datePickerOverlay)
        view.sendSubview(toBack: datePickerOverlay)
        
        //Set up table view
        routeResults = UITableView(frame: CGRect(x: 0, y: routeSelection.frame.maxY, width: view.frame.width, height: view.frame.height - routeSelection.frame.height - (navigationController?.navigationBar.frame.height ?? 0) - UIApplication.shared.statusBarFrame.height))
        routeResults.delegate = self
        routeResults.allowsSelection = true
        routeResults.dataSource = self
        routeResults.separatorStyle = .none
        routeResults.backgroundColor = .tableBackgroundColor
        routeResults.alwaysBounceVertical = false //so table view doesn't scroll over top & bottom
        view.addSubview(routeResults)
        view.addSubview(datePickerView)//so datePicker can go ontop of other views

        //If no date is set then date should be same as today's date
        guard let _ = searchTime else{
            searchTime = Date()
            return
        }
        
        //Set up fake data
        let date1 = Time.date(from: "8:45 PM")
        let date2 = Time.date(from: "9:52 PM")
        let route1 = Route(departureTime: date1, arrivalTime: date2, directions: [], mainStops: ["Baker Flagpole", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
        
        let date3 = Time.date(from: "10:12 PM")
        let date4 = Time.date(from: "10:47 PM")
        let route2 = Route(departureTime: date3, arrivalTime: date4, directions: [], mainStops: ["Annabel Taylor Hall", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
        
        let date5 = Time.date(from: "11:12 PM")
        let date6 = Time.date(from: "11:38 PM")
        let route3 = Route(departureTime: date5, arrivalTime: date6, directions: [], mainStops: ["Baker Flagpole", "Schwartz Center", "Commons - Seneca Street"], mainStopsNums: [90, 32, -1], travelDistance: 0.1)
        
        loaderroutes = [route1, route2, route3]
        routes = loaderroutes
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        routeResults.register(RouteTableViewCell.self, forCellReuseIdentifier: identifier)
        self.title = "Route Options"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        Loader.addLoaderTo(routeResults)
//        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(, userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: Search bar functionality
    func searchForRoutes(){
        if searchTime == nil{
            searchTime = Date()
        }
        let (fromBus, fromPlace) = searchFrom
        let (toBus, toPlace) = searchTo
        if let startBus = fromBus, let endBus = toBus{
            Network.getRoutes(start: startBus, end: endBus, time: searchTime!, type: searchTimeType).perform(withSuccess: { (routes) in
                self.routes = self.getValidRoutes(routes: routes)
                self.routeResults.reloadData()
                self.loaded()
            }, failure: { (error) in
                print("Error: \(error)")
                self.routes = []
                self.routeResults.reloadData()
                self.loaded()
            })
        }
        if let startBus = fromBus, let endPlace = toPlace{
            Network.getRoutes(start: startBus, end: endPlace, time: searchTime!, type: searchTimeType).perform(withSuccess: { (routes) in
                self.routes = self.getValidRoutes(routes: routes)
                self.routeResults.reloadData()
                self.loaded()
            }, failure: { (error) in
                print("Error: \(error)")
                self.routes = []
                self.routeResults.reloadData()
                self.loaded()
            })
        }
        if let startPlace = fromPlace, let endBus = toBus{
            Network.getRoutes(start: startPlace, end: endBus, time: searchTime!, type: searchTimeType).perform(withSuccess: { (routes) in
                self.routes = self.getValidRoutes(routes: routes)
                self.routeResults.reloadData()
                self.loaded()
            }, failure: { (error) in
                print("Error: \(error)")
                self.routes = []
                self.routeResults.reloadData()
                self.loaded()
            })
        }
        if let startPlace = fromPlace, let endPlace = toPlace{
            Network.getRoutes(start: startPlace, end: endPlace, time: searchTime!, type: searchTimeType).perform(withSuccess: { (routes) in
                self.routes = self.getValidRoutes(routes: routes)
                self.routeResults.reloadData()
                self.loaded()
            }, failure: { (error) in
                print("Error: \(error)")
                self.routes = []
                self.routeResults.reloadData()
                self.loaded()
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
                            if self.searchTimeType == .leaveat{ //make sure if walk now to stop, get there before leaveat time
                                let walkToStopDate = Date().addingTimeInterval(walkTimeInterval)
                                if(walkToStopDate > self.searchTime!){
                                    validRoute = false
                                }
                            }else{ //make sure walk to stop before bus leaves
                                let walkToStopDate = self.searchTime?.addingTimeInterval(walkTimeInterval)
                                if(walkToStopDate! > route.directions[1].time){
                                    validRoute = false
                                }
                            }
                        })
                    }else if i == (directions.count - 1){
                        walkDir.calculateWalkingDirections({ (distance, walkTimeInterval) in
                            if self.searchTimeType == .arriveby { //make sure walk to destination before arrive by time
                                let walkToDestinationDate = route.directions[i-1].time.addingTimeInterval(walkTimeInterval)
                                if(walkToDestinationDate > self.searchTime!){
                                    validRoute = false
                                }
                            }
                        })
                    }else{ //make sure can walk from previous stop and arrive to next stop by the time bus departs
                        walkDir.calculateWalkingDirections({ (distance, walkTimeInterval) in
                            let walkToStopDate = route.directions[i-1].time.addingTimeInterval(walkTimeInterval)
                            if(walkToStopDate > route.directions[i+1].time){
                                validRoute = false
                            }
                        })
                    }
                }
            }
            if (validRoute) {validroutes.append(route)}
        }
        return validroutes
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        locationManager.stopUpdatingLocation()
        print("didFailWithError: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse
            || status == CLAuthorizationStatus.authorizedAlways {
            print("Requesting Location")
            //locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //If don't have start location, set to current location
        locationManager.stopUpdatingLocation()
        if searchFrom.0 == nil, let location = manager.location {
            let currentLocationStop =  BusStop(name: "Current Location", lat: location.coordinate.latitude, long: location.coordinate.longitude)
            searchFrom.0 = currentLocationStop
            searchBarView.resultsViewController?.currentLocation = currentLocationStop
            routeSelection.fromSearch.setTitle(searchFrom.0?.name, for: .normal)
            searchForRoutes()
        }
    }
    
    func searchingTo(sender: UIButton){
        searchType = .to
        presentSearchBar()
    }
    
    func searchingFrom(sender: UIButton){
        searchType = .from
        presentSearchBar()
    }
    
    func presentSearchBar(){
        //Unhide search bar
        navigationItem.titleView = searchBarView.searchController?.searchBar
        searchBarView.searchController?.isActive = true
        //Customize placeholder
        let placeholder = (searchType == .from) ? "Search start locations" : "Search destination"
        let textFieldInsideSearchBar = searchBarView.searchController?.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(string: placeholder) //make placeholder invisible
        //Prompt search
        //searchBarView.searchController?.searchBar.text = (searchType == .from) ? routeSelection.fromSearch.titleLabel?.text : routeSelection.toSearch.titleLabel?.text
    }
    
    func didSelectDestination(busStop: BusStop?, placeResult: PlaceResult?){
        switch searchType{
            case .from:
                if let result = busStop{
                    searchFrom = (result, nil)
                    routeSelection.fromSearch.setTitle(result.name, for: .normal)
                }else if let result = placeResult{
                    searchFrom = (nil, result)
                    routeSelection.fromSearch.setTitle(result.name, for: .normal)                }
            default:
                if let result = busStop{
                    searchTo = (result, nil)
                    routeSelection.toSearch.setTitle(result.name, for: .normal)
                }else if let result = placeResult{
                    searchTo = (nil, result)
                    routeSelection.toSearch.setTitle(result.name, for: .normal)
                }
        }
        //Hide & dismiss search bar
        navigationItem.titleView = nil
        searchBarView.searchController?.isActive = false
        searchBarView.searchController?.dismiss(animated: true, completion: nil)
        //Make network search
        searchForRoutes()
    }
    
    func didCancel(){
        //Hide search bar
        navigationItem.titleView = nil
        searchBarView.searchController?.isActive = false

    }
    
    //MARK: Loader functionality
    func loaded()
    {
        Loader.removeLoaderFrom(routeResults)
    }
    
    //MARK: Datepicker functionality
    func showDatePicker(sender: UIButton){
        view.bringSubview(toFront: datePickerOverlay)
        view.bringSubview(toFront: datePickerView)
        UIView.animate(withDuration: 0.5) { 
            self.datePickerView.center.y = self.view.frame.height - (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.7
        }
    }
    
    func dismissDatePicker(sender: UIButton){
        UIView.animate(withDuration: 0.5, animations: { 
            self.datePickerView.center.y = self.view.frame.height + (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.0
        }) { (true) in
            self.view.sendSubview(toBack: self.datePickerOverlay)
            self.view.sendSubview(toBack: self.datePickerView)
        }
    }
    
    func saveDatePickerDate(sender: UIButton){
        let date = datePickerView.datePicker.date
        searchTime = date
        let dateString = Time.fullString(from: date)
        let segmentedControl = datePickerView.arriveDepartBar
        let selectedSegString = (segmentedControl?.titleForSegment(at: segmentedControl?.selectedSegmentIndex ?? 0)) ?? ""
        if (selectedSegString.lowercased().contains("arrive")){
            searchTimeType = .arriveby
        }else{
            searchTimeType = .leaveat
        }
        var title = ""
        //Customize string based on date
        if(Calendar.current.isDateInToday(date) || Calendar.current.isDateInTomorrow(date)){
            let verb = (searchTimeType == .arriveby) ? "Arrive" : "Leave" //Use simply,"arrive" or "leave"
            let day = Calendar.current.isDateInToday(date) ? "" : " tomorrow" //if today don't put day
            title = "\(verb)\(day) at \(Time.string(from: date))"
        }else{
            let verb = (searchTimeType == .arriveby) ? "Arrive by" : "Leave on" //Use "arrive by" or "leave on"
            title = "\(verb) \(dateString)"
        }
        routeSelection.timeButton.setTitle(title, for: .normal)
        
        //dismiss datepicker view
        dismissDatePicker(sender: sender)
        
        //Search for routes
        searchForRoutes()
    }
    
    
    //MARK: Tableview Data Source & Delegate
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool{
       navigationController?.pushViewController(RouteDetailViewController(route: routes[indexPath.row]), animated: true)
        return false // halts the selection process = don't have selected look
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? RouteTableViewCell
        
        if cell == nil {
            cell = RouteTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        
        cell?.departureTime = routes[indexPath.row].departureTime
        cell?.arrivalTime = routes[indexPath.row].arrivalTime
        cell?.stops = routes[indexPath.row].mainStops
        cell?.busNums = routes[indexPath.row].mainStopsNums
        cell?.distance = routes[indexPath.row].travelDistance
        cell?.setData()
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "Route Results"
    
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = .tableBackgroundColor
        header.textLabel?.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        header.textLabel?.textColor = UIColor.secondaryTextColor
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let spaceYTimeLabelFromSuperviewTop: CGFloat = 18.0
        let travelTimeHeight: CGFloat = 17.0
        let spaceYTimeLabelAndDot: CGFloat = 26.0
        let heightDot: CGFloat = 8.0
        let lineLengthYBtDots: CGFloat = 21.0
        
        let spaceBtDotAndLineDot: CGFloat = 17.0
        let heightLineDot: CGFloat = 16.0
        let spaceYToCellBorder: CGFloat = 18.0
        let cellBorderWidthY: CGFloat = 0.75
        let cellSpaceWidthY: CGFloat = 4.0
        
        let numOfDots = routes[indexPath.row].mainStops.count - 1 //1 less b/c last dot is line dot
        let numOfLinesBtDots = numOfDots - 1
        
        let  headerHeight = spaceYTimeLabelFromSuperviewTop + travelTimeHeight + spaceYTimeLabelAndDot
        let dotsHeight = CGFloat(numOfDots)*heightDot + CGFloat(numOfLinesBtDots)*lineLengthYBtDots + spaceBtDotAndLineDot + heightLineDot
        let footerHeight = spaceYToCellBorder + cellBorderWidthY + cellSpaceWidthY
        return (headerHeight + dotsHeight + footerHeight)
    }
}
