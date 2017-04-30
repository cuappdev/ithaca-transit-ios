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
  * Make Github issue for Shiv
  * Add Matt's logic
  * My title is not showing up??
  * Austin to Mine's = fix back button to Matt's custom back button
  * deque = the line keeps showing up ??
  * Loader = fix
 */
/* Austin - when run on my phone don't see any search results
  *
 */
/* Later:
  * PlaceResult & BuSStop really cannot be 2 different objects, cause too much hassle. N2Do inheritance
  * selection style for cells?
  * Get rid of random print statements
 */
enum SearchType: String{
    case from, to
}

enum SearchObject: String{
    case placeresult, busstop
}

enum SearchDeparture: String{
    case arriveby, leaveat
}

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    DestinationDelegate, SearchBarCancelDelegate,UISearchBarDelegate,
    CLLocationManagerDelegate {
    
    //Search bar
    var searchBarView: SearchBarView!
    var locationManager: CLLocationManager!
        //Fill search data w/ default values
    var searchType: SearchType = .from //for search bar
    var searchFrom: (SearchObject, AnyObject?) = (.busstop, nil)
    var searchTo: (SearchObject, AnyObject?) = (.busstop, nil)
    var searchDeparture: SearchDeparture? = .leaveat
    var searchDate: Date? = Date()
    
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
        if let selectedDestination = searchTo.1 {
            //set search text to either bus stop or place result
            if let bustitle = (selectedDestination as? BusStop)?.name{
               routeSelection.toSearch.setTitle(bustitle, for: .normal)
            }
            if let placetitle  = (selectedDestination as? PlaceResult)?.name{
                routeSelection.toSearch.setTitle(placetitle, for: .normal)
            }
        }
        
        //Set up location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        //Use users current location if no starting point set
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse
                || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways {
                locationManager.requestLocation()
            }
            else{
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
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
        guard let _ = searchDate else{
            searchDate = Date()
            return
        }
        
        //Set up fake data
        let date1 = Time.date(from: "3:45 PM")
        let date2 = Time.date(from: "3:52 PM")
        let route1 = Route(departureTime: date1, arrivalTime: date2, directions: [], mainStops: ["Baker Flagpole", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
        
        let date3 = Time.date(from: "12:12 PM")
        let date4 = Time.date(from: "12:47 PM")
        let route2 = Route(departureTime: date3, arrivalTime: date4, directions: [], mainStops: ["Annabel Taylor Hall", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
        
        let date5 = Time.date(from: "1:12 PM")
        let date6 = Time.date(from: "1:38 PM")
        let route3 = Route(departureTime: date5, arrivalTime: date6, directions: [], mainStops: ["Baker Flagpole", "Schwartz Center", "Commons - Seneca Street"], mainStopsNums: [90, 32, -1], travelDistance: 0.1)
        
        loaderroutes = [route1, route2, route3]
        routes = loaderroutes
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        routeResults.register(RouteTableViewCell.self, forCellReuseIdentifier: identifier)
        self.title = "Route Options"

    }
    
    override func viewDidAppear(_ animated: Bool) {
//        Loader.addLoaderTo(routeResults)
//        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(, userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: Search bar functionality
    func searchForRoutes(){
        //N2SELF: N2 put in parameters for searchDate & searchDepature
        if let startBus = searchFrom.1 as? BusStop, let end = searchTo.1 {
            switch searchTo.0 {
            case .busstop:
                if let endBus = end as? BusStop{
                    routes = loaderroutes
                    Loader.addLoaderTo(routeResults)
                    routeResults.reloadData()
                    Network.getBusRoute(startLat: startBus.lat!, startLng: startBus.long!, destLat: endBus.lat!, destLng: endBus.long!).perform(withSuccess: { (routes) in
                        print("success")
//                        routes.map({ route in
//                            route.directions.map({ (direction) in
//                                <#code#>
//                            })
//                        })
                        self.routes = routes
                        self.routeResults.reloadData()
                        self.loaded()
                    }, failure: { (error) in
                        print("Error: \(error)")
                        self.routes = []
                        self.routeResults.reloadData()
                        self.loaded()
                    })
                }
            default: //place result
                if let endPlace = end as? PlaceResult{
                    Loader.addLoaderTo(routeResults)
                    routes = loaderroutes
                    routeResults.reloadData()
                    Network.getPlaceRoute(startLat: startBus.lat!, startLng: startBus.long!, destPlaceID: endPlace.placeID!).perform(withSuccess: { (routes) in
                        self.routes = routes
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
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        locationManager.stopUpdatingLocation()
        print("didFailWithError: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse
            || status == CLAuthorizationStatus.authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //If don't have start location, set to current location
        if searchFrom.1 == nil, let location = manager.location{
            searchFrom.1 = BusStop(name: "Current Location", lat: location.coordinate.latitude, long: location.coordinate.longitude)
            routeSelection.fromSearch.setTitle((searchFrom.1 as? BusStop)?.name, for: .normal)
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
        searchBarView.searchController?.searchBar.text = (searchType == .from) ? routeSelection.fromSearch.titleLabel?.text : routeSelection.toSearch.titleLabel?.text
    }
    
    func didSelectDestination(busStop: BusStop?, placeResult: PlaceResult?){
        switch searchType{
            case .from:
                if let result = busStop{
                    searchFrom = (.busstop, result)
                    routeSelection.fromSearch.setTitle(result.name, for: .normal)
                }else if let result = placeResult{
                    searchFrom = (.busstop, result)
                    routeSelection.fromSearch.setTitle(result.name, for: .normal)                }
            default:
                if let result = busStop{
                    searchTo = (.busstop, result)
                    routeSelection.toSearch.setTitle(result.name, for: .normal)
                }else if let result = placeResult{
                    searchTo = (.busstop, result)
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
        print("delegate called")
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
        searchDate = date
        let dateString = Time.fullString(from: date)
        let segmentedControl = datePickerView.arriveDepartBar
        let selectedSegString = (segmentedControl?.titleForSegment(at: segmentedControl?.selectedSegmentIndex ?? 0)) ?? ""
        if (selectedSegString.lowercased().contains("arrive")){
            searchDeparture = .arriveby
        }else{
            searchDeparture = .leaveat
        }
        var title = ""
        //Customize string based on date
        if(Calendar.current.isDateInToday(date) || Calendar.current.isDateInTomorrow(date)){
            let verb = (searchDeparture == .arriveby) ? "Arrive" : "Leave" //Use simply,"arrive" or "leave"
            let day = Calendar.current.isDateInToday(date) ? "" : " tomorrow" //if today don't put day
            title = "\(verb)\(day) at \(Time.string(from: date))"
        }else{
            let verb = (searchDeparture == .arriveby) ? "Arrive by" : "Leave on" //Use "arrive by" or "leave on"
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
