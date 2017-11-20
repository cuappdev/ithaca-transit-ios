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


class SearchResultsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, CLLocationManagerDelegate, UnwindAllStopsTVCDelegate, UINavigationControllerDelegate {
    
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
    var favoritesSection: Section!
    var recentLocations: [ItemType] = []
    var favorites: [ItemType] = []
    var initialTableViewIndexMinY: CGFloat!
    var isKeyboardVisible = false
    var shouldShowCurrentLocation = true
    var returningFromAllStopsTVC = false
    var returningFromAllStopsBusStop: BusStop?
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
        
        //Fetch RecentLocation and Favorites
        recentLocations = SearchTableViewManager.shared.retrieveRecentPlaces(for: Key.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrieveRecentPlaces(for: Key.UserDefaults.favorites)
        
        // Set Up TableView
        tableView.register(BusStopCell.self, forCellReuseIdentifier: Key.Cells.busIdentifier)
        tableView.register(BusStopCell.self, forCellReuseIdentifier: Key.Cells.currentLocationIdentifier)
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: Key.Cells.searchResultsIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Key.Cells.seeAllStopsIdentifier)
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
        seeAllStopsSection = Section(type: .seeAllStops, items: [.seeAllStops])
        recentSearchesSection = Section(type: .recentSearches, items: recentLocations)
        favoritesSection = Section(type: .favorites, items: favorites)
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
        allSections.append(favoritesSection)
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
    @objc func keyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
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
        case .favorites: return favorites.count
        case .seeAllStops, .searchResults, .currentLocation: return sections[section].items.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderView()

        switch sections[section].type {
        case .cornellDestination:
            header.setupView(labelText: "Get There Now", displayAddButton: false)
        case .recentSearches:
            header.setupView(labelText: "Recent Searches", displayAddButton: false)
        case .favorites:
            header.setupView(labelText: "Favorite Destinations", displayAddButton: false)
        case .seeAllStops, .searchResults:
            return nil
        default: break
        }

        return header
    }

   override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section].type {
        case .favorites, .recentSearches: return 50
        default: return 24
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
        case .recentSearches, .searchResults, .seeAllStops, .currentLocation, .favorites:
            itemType = sections[indexPath.section].items[indexPath.row]
        }
        
        switch itemType {
        case .seeAllStops:
            didSelectAllStops = true
            allStopsTVC.allStops = SearchTableViewManager.shared.getAllStops()
            allStopsTVC.unwindAllStopsTVCDelegate = self
        case .busStop(let busStop):
            if busStop.name != "Current Location" && busStop.name != Key.Favorites.first {
                SearchTableViewManager.shared.insertPlace(for: Key.UserDefaults.recentSearch, location: busStop, limit: 8)
            }
            //Crashlytics Answers
            Answers.destinationSearched(destination: busStop.name, stopType: "bus stop")
            
            destinationDelegate?.didSelectDestination(busStop: busStop, placeResult: nil)
        case .placeResult(let placeResult):
            SearchTableViewManager.shared.insertPlace(for: Key.UserDefaults.recentSearch, location: placeResult, limit: 8)
            //Crashlytics Answers
            Answers.destinationSearched(destination: placeResult.name, stopType: "google place")
            
            destinationDelegate?.didSelectDestination(busStop: nil, placeResult: placeResult)
        default: break
        }
        definesPresentationContext = false
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar?.endEditing(true)
        if didSelectAllStops {
            if let parentIsSearch = self.parent?.isKind(of: UISearchController.self), parentIsSearch {
                let navController = self.parent?.presentingViewController?.navigationController
                navController?.delegate = self
                allStopsTVC.navController = navController
                navController?.pushViewController(allStopsTVC, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var itemType : ItemType?
        var cell: UITableViewCell!
        
        switch sections[indexPath.section].type {
        case .cornellDestination:
            itemType = .cornellDestination
        case .recentSearches, .seeAllStops, .searchResults, .currentLocation, .favorites:
            itemType = sections[indexPath.section].items[indexPath.row]
        }
        
        if let itemType = itemType {
            switch itemType {
            case .busStop(let busStop):
                let identifier = busStop.name == "Current Location" ? Key.Cells.currentLocationIdentifier : Key.Cells.busIdentifier
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! BusStopCell
                cell.textLabel?.text = busStop.name
            case .placeResult(let placeResult):
                cell = tableView.dequeueReusableCell(withIdentifier: Key.Cells.searchResultsIdentifier) as! SearchResultsCell
                cell.textLabel?.text = placeResult.name
                cell.detailTextLabel?.text = placeResult.detail
            case .seeAllStops:
                cell = tableView.dequeueReusableCell(withIdentifier: Key.Cells.seeAllStopsIdentifier)
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
    @objc func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if searchText.count > 0 {
            Network.getGooglePlaces(searchText: searchText).perform(withSuccess: { responseJson in
                self.searchResultsSection = SearchTableViewManager.shared.parseGoogleJSON(searchText: searchText, json: responseJson)
                self.sections = self.searchResultsSection.items.isEmpty ? [] : [self.searchResultsSection]
                //self.tableViewIndexController.setHidden(true, animated: false)
                if !self.sections.isEmpty {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false) }
            })
        } else {
            sections = createSections()
        }
    }
    
    /* ScrollView Delegate*/
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cancelButton = searchBar?.value(forKey: "_cancelButton") as? UIButton {
            cancelButton.isEnabled = true
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

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if returningFromAllStopsTVC, let busStop = returningFromAllStopsBusStop {
            destinationDelegate?.didSelectDestination(busStop: busStop, placeResult: nil)
        }
    }

    func dismissSearchResultsVC(busStop: BusStop) {
        returningFromAllStopsBusStop = busStop
        returningFromAllStopsTVC = true
    }
}
