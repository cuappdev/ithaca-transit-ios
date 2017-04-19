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

/* Main:
  * get users current location = autofill
  * search bar not searching??
  * pull Matt's changes - does back button now work?
  * call loader appropriatley
 */

/* Things to fix:
  * PlaceResult & BuSStop really cannot be 2 different objects, cause too much hassle. N2Do inheritance
  * Austin: Fix glitch w/ recent searches. Does not send correct text
 */

/* Things to consider:
  * selection style for cells?
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
    var locationManager: CLLocationManager = CLLocationManager()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up navigation bar
        title = "Route Options"
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
        searchBarView.searchController?.searchBar.sizeToFit()
        self.definesPresentationContext = true
            //Hide search bar
        navigationItem.titleView = nil
        searchBarView.searchController?.isActive = false

        routeSelection.toSearch.addTarget(self, action: #selector(self.searchingTo), for: .touchUpInside)
        routeSelection.fromSearch.addTarget(self, action: #selector(self.searchingFrom), for: .touchUpInside)
        
        //Autofill destination if user has already selected one from previous screen
        if let selectedDestination = searchTo.1 {
            //set search text to either bus stop or place result
            var title = (selectedDestination as? BusStop)?.name
            title  = (selectedDestination as? PlaceResult)?.name
            routeSelection.toSearch.setTitle(title, for: .normal)
        }
        /*
        //Ask user for location
        locationManager = CLLocationManager()
//        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
//        }
        
        //Use users current location if no starting point set
        if CLLocationManager.locationServicesEnabled() {
            let locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }*/
        
        //Ask user for location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Use users current location if no starting point set
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse
                || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways {
                locationManager.startUpdatingLocation()
            }
            else{
                locationManager.requestWhenInUseAuthorization()
            }
        }
        else{
            //Alert user to open location service, bra bra bra here...
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
        
        //Set up test data
//        let date1 = Time.date(from: "3:45 PM")
//        let date2 = Time.date(from: "3:52 PM")
//        let route1 = Route(departureTime: date1, arrivalTime: date2, directions: [], mainStops: ["Baker Flagpole", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
//        
//        let date3 = Time.date(from: "12:12 PM")
//        let date4 = Time.date(from: "12:47 PM")
//        let route2 = Route(departureTime: date3, arrivalTime: date4, directions: [], mainStops: ["Annabel Taylor Hall", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
//        
//        let date5 = Time.date(from: "1:12 PM")
//        let date6 = Time.date(from: "1:38 PM")
//        let route3 = Route(departureTime: date5, arrivalTime: date6, directions: [], mainStops: ["Baker Flagpole", "Schwartz Center", "Commons - Seneca Street"], mainStopsNums: [90, 32, -1], travelDistance: 0.1)
//        
//        routes = [route1, route2, route3]
        
        searchForRoutes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        routeResults.register(RouteTableViewCell.self, forCellReuseIdentifier: identifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        Loader.addLoaderTo(routeResults)
//        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.loaded), userInfo: nil, repeats: false)
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
                    Network.getBusRoute(startLat: startBus.lat!, startLng: startBus.long!, destLat: endBus.lat!, destLng: endBus.long!).perform(withSuccess: { (routes) in
                        self.routes = routes
                        self.routeResults.reloadData()
                    }, failure: { (error) in
                        print("Error: \(error)")
                    })
                }
            default: //place result
                if let endPlace = end as? PlaceResult{
                    Network.getPlaceRoute(startLat: startBus.lat!, startLng: startBus.long!, destPlaceID: endPlace.placeID!).perform(withSuccess: { (routes) in
                        self.routes = routes
                        self.routeResults.reloadData()
                    }, failure: { (error) in
                        print("Error: \(error)")
                    })
                }
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization")
        if status == CLAuthorizationStatus.authorizedWhenInUse
            || status == CLAuthorizationStatus.authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        else{
            //other procedures when location service is not permitted.
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        locationManager.stopUpdatingLocation()
        print("didFailWithError")
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did update location called?")
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
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
