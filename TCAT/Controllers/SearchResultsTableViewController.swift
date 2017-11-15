//
//  SearchResultsTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreLocation
import DZNEmptyDataSet
import Crashlytics


protocol DestinationDelegate {
    func didSelectDestination(busStop: BusStop?, placeResult: PlaceResult?)
}
protocol SearchBarCancelDelegate {
    func didCancel()
}


class SearchResultsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, CLLocationManagerDelegate {
    
    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    
    var currentLocation: BusStop?
    var destinationDelegate: DestinationDelegate?
    var searchBarCancelDelegate: SearchBarCancelDelegate?
    var timer: Timer?
    var searchBar: UISearchBar?
    var recentSearchesSection: Section!
    var seeAllStopsSection: Section!
    var searchResultsSection: Section!
    var currentLocationSection: Section!
    var sectionIndexes: [String: Int]!
    var recentLocations: [ItemType] = []
    var initialTableViewIndexMinY: CGFloat!
    var isKeyboardVisible = false
    var shouldShowCurrentLocation = true
    var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    func tctSectionHeaderFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 14)
    }
    
    convenience init() {
        self.init(style: .grouped)
    }

    override func viewWillAppear(_ animated: Bool) {
        searchBar?.sizeToFit()
        searchBar?.tintColor = UIColor.primaryTextColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Subscribe to Keyboard Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        //Create SectionIndexes & Fetch RecentLocations
        sectionIndexes = sectionIndexesForBusStop()
        recentLocations = retrieveRecentLocations()
        
        // Set Up TableView
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "busStops")
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "currentLocation")
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: "searchResults")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "seeAllStops")
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexColor = .primaryTextColor
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .tableBackgroundColor
        tableView.showsVerticalScrollIndicator = false
        tableView.reloadData()
        extendedLayoutIncludesOpaqueBars = true
        
        // Set Up LocationManager
        locationManager.delegate = self
        if shouldShowCurrentLocation {
            locationManager.requestLocation()
        }
        
        //Set Up Sections For TableView
//        let allBusStops = getAllBusStops()
        seeAllStopsSection = Section(type: .seeAllStops, items: [.seeAllStops])
        recentSearchesSection = Section(type: .recentSearches, items: recentLocations)
        searchResultsSection = Section(type: .searchResults, items: [])
        if let currentLocation = currentLocation {
            currentLocationSection = Section(type: .currentLocation, items: [.busStop(currentLocation)])
        }

        sections = createSections()
        searchBar?.becomeFirstResponder()
        searchBar?.tintColor = .searchBarCursorColor

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createSections() -> [Section] {
        var allSections: [Section] = []
        if currentLocationSection != nil {
            allSections.append(currentLocationSection)
        }
        allSections.append(recentSearchesSection)
        allSections.append(seeAllStopsSection)
        return allSections.filter({$0.items.count > 0})
    }
    
    /* Location Manager Delegates */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let firstLocation = locations.first, currentLocationSection.items.isEmpty {
            let currentLocationBusItem = ItemType.busStop(BusStop(name: "Current Location", lat: firstLocation.coordinate.latitude, long: firstLocation.coordinate.longitude))
            currentLocationSection = Section(type: .currentLocation, items: [currentLocationBusItem])
            sections = createSections()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("SearchResultsTableVC CLLocationManager didFailWithError: \(error)")
    }
    
    /* Keyboard Functions */
    func keyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
    }
    
    func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
    }
    
    /* TableView Methods */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section].type {
        case .cornellDestination: return 0
        case .recentSearches: return recentLocations.count
        case .seeAllStops, .searchResults, .currentLocation: return sections[section].items.count
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .secondaryTextColor
        header.textLabel?.font = tctSectionHeaderFont()
        switch sections[section].type {
        case .recentSearches: header.textLabel?.text = "Recent Searches"
        case .searchResults, .seeAllStops, .currentLocation, .cornellDestination: header.textLabel?.text = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section].type {
        case .cornellDestination: return "Get There Now"
        case .recentSearches: return "Recent Searches"
        case .searchResults, .seeAllStops, .currentLocation: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var itemType: ItemType
        var didSelectAllStops = false
        let allStopsTVC = AllStopsTableViewController()
        
        switch sections[indexPath.section].type {
        case .cornellDestination:
            itemType = .cornellDestination
        case .recentSearches, .searchResults, .seeAllStops, .currentLocation:
            itemType = sections[indexPath.section].items[indexPath.row]
        }
        
        switch itemType {
        case .seeAllStops:
            print("DID SELECT SEE ALL STOPS")
            didSelectAllStops = true


        case .busStop(let busStop):
            if busStop.name != "Current Location" {
                insertRecentLocation(location: busStop)
            }
            //Crashlytics Answers
            Answers.destinationSearched(destination: busStop.name, stopType: "bus stop")
            
            destinationDelegate?.didSelectDestination(busStop: busStop, placeResult: nil)
        case .placeResult(let placeResult):
            insertRecentLocation(location: placeResult)
            //Crashlytics Answers
            Answers.destinationSearched(destination: placeResult.name, stopType: "google place")
            
            destinationDelegate?.didSelectDestination(busStop: nil, placeResult: placeResult)
        default: break
        }
        definesPresentationContext = false
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar?.endEditing(true)
        if didSelectAllStops {
            navigationController?.pushViewController(allStopsTVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var itemType : ItemType?
        var cell: UITableViewCell!
        
        switch sections[indexPath.section].type {
        case .cornellDestination:
            itemType = .cornellDestination
        case .recentSearches, .seeAllStops, .searchResults, .currentLocation:
            itemType = sections[indexPath.section].items[indexPath.row]
        }
        
        if let itemType = itemType {
            switch itemType {
            case .busStop(let busStop):
                let identifier = busStop.name == "Current Location" ? "currentLocation" : "busStops"
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! BusStopCell
                cell.textLabel?.text = busStop.name
            case .placeResult(let placeResult):
                cell = tableView.dequeueReusableCell(withIdentifier: "searchResults") as! SearchResultsCell
                cell.textLabel?.text = placeResult.name
                cell.detailTextLabel?.text = placeResult.detail
            case .seeAllStops:
                cell = tableView.dequeueReusableCell(withIdentifier: "seeAllStops")
                cell.textLabel?.text = "See All Stops"
                cell.imageView?.image = #imageLiteral(resourceName: "list")
                cell.accessoryType = .disclosureIndicator
            default: break
            }
        }
        cell.textLabel?.font = tctSectionHeaderFont()
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.layoutSubviews()
        
        
        return cell
    }
    
    /* Fetch Search Results*/
    func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if searchText.characters.count > 0 {
            Network.getGooglePlaces(searchText: searchText).perform(withSuccess: { responseJson in
                self.searchResultsSection = parseGoogleJSON(searchText: searchText, json: responseJson)
                self.sections = self.searchResultsSection.items.isEmpty ? [] : [self.searchResultsSection]
                //self.tableViewIndexController.setHidden(true, animated: false)
                if !self.sections.isEmpty {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false) }
            })
        } else {
            sections = createSections()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
            //self.tableViewIndexController.setHidden(false, animated: false)
            
        }
    }
    
    /* ScrollView Delegate*/
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cancelButton = searchBar?.value(forKey: "_cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
        let contentOffsetY = scrollView.contentOffset.y
        if scrollView == tableView && searchBar?.text == "" && !isKeyboardVisible {
            //setUpIndexBar(contentOffsetY: contentOffsetY)
        }
    }
    
    /* SearchBar Delegates */
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //tableViewIndexController.setHidden(true, animated: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelDelegate?.didCancel()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(getPlaces), userInfo: ["searchText": searchText], repeats: false)
    }
}
