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

class SearchResultsTableViewController: UITableViewController {

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
        return UIFont.style(Fonts.System.regular, size: 14)
    }

    convenience init() {
        self.init(style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Subscribe to Keyboard Notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        //Fetch RecentLocation and Favorites
        recentLocations = SearchTableViewManager.shared.retrieveRecentPlaces(for: Constants.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrieveRecentPlaces(for: Constants.UserDefaults.favorites)

        // Set Up TableView
        tableView.register(BusStopCell.self, forCellReuseIdentifier: Constants.Cells.busIdentifier)
        tableView.register(BusStopCell.self, forCellReuseIdentifier: Constants.Cells.currentLocationIdentifier)
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: Constants.Cells.searchResultsIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cells.seeAllStopsIdentifier)
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexColor = .primaryTextColor
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .tableBackgroundColor
        tableView.showsVerticalScrollIndicator = false
        tableView.reloadData()

        // Set Up LocationManager
        locationManager.delegate = self

        // Set Up Sections For TableView
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar?.sizeToFit()
        searchBar?.tintColor = .primaryTextColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldShowCurrentLocation {
            locationManager.requestLocation()
        }
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
        return allSections.filter { !$0.items.isEmpty }
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
        case .cornellDestination:
            return 0
        case .recentSearches:
            return recentLocations.count
        case .favorites:
            return favorites.count
        default:
            return sections[section].items.count
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
        default:
            break
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
            if busStop.lat == 0.0 && busStop.long == 0.0 {
                showLocationDeniedAlert()
                return
            }

            if busStop.name != Constants.Stops.currentLocation
                && busStop.name != Constants.Phrases.firstFavorite {
                SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.recentSearch,
                                                          location: busStop,
                                                          limit: 8)
            }

            let payload = BusStopTappedPayload(name: busStop.name)
            Analytics.shared.log(payload)

            destinationDelegate?.didSelectDestination(busStop: busStop, placeResult: nil)
        case .placeResult(let placeResult):
            SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.recentSearch,
                                                      location: placeResult,
                                                      limit: 8)

            let payload = GooglePlaceTappedPayload(name: placeResult.name)
            Analytics.shared.log(payload)

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
                navController?.pushViewController(allStopsTVC, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var itemType: ItemType?
        var cell: UITableViewCell!

        switch sections[indexPath.section].type {
        case .cornellDestination:
            itemType = .cornellDestination
        default:
            itemType = sections[indexPath.section].items[indexPath.row]
        }

        if let itemType = itemType {
            switch itemType {
            case .busStop(let busStop):
                let identifier = busStop.name == Constants.Stops.currentLocation ?
                    Constants.Cells.currentLocationIdentifier : Constants.Cells.busIdentifier
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BusStopCell
                cell.textLabel?.text = busStop.name
            case .placeResult(let placeResult):
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.searchResultsIdentifier) as? SearchResultsCell
                cell.textLabel?.text = placeResult.name
                cell.detailTextLabel?.text = placeResult.detail
            case .seeAllStops:
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.seeAllStopsIdentifier)
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
}

// MARK: ScrollView Delegate
extension SearchResultsTableViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cancelButton = searchBar?.value(forKey: "_cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
    
    func showLocationDeniedAlert() {
        let alertController = UIAlertController(title: "Location Services Disabled",
                                                message: "You need to enable Location Services in Settings",
                                                preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                      options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                      completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: {
            self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
        })
    }
}

// MARK: Search Bar Delegate
extension SearchResultsTableViewController: UISearchBarDelegate, UISearchResultsUpdating {

    @objc func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if !searchText.isEmpty {
            Network.getGooglePlacesAutocompleteResults(searchText: searchText).perform(withSuccess: { responseJson in
                self.searchResultsSection = SearchTableViewManager.shared.parseGoogleJSON(searchText: searchText, json: responseJson)
                self.sections = self.searchResultsSection.items.isEmpty ? [] : [self.searchResultsSection]
                // self.tableViewIndexController.setHidden(true, animated: false)
                if !self.sections.isEmpty {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
            })
        } else {
            sections = createSections()
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        if !sections.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        searchController.searchResultsController?.view.isHidden = false
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // tableViewIndexController.setHidden(true, animated: false)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelDelegate?.didCancel()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2,
                                     target: self,
                                     selector: #selector(getPlaces),
                                     userInfo: ["searchText": searchText],
                                     repeats: false)
    }
}

extension SearchResultsTableViewController: UnwindAllStopsTVCDelegate {
    func dismissSearchResultsVC(busStop: BusStop) {
        returningFromAllStopsBusStop = busStop
        returningFromAllStopsTVC = true
    }
}

// MARK: - Location Manager Delegates
extension SearchResultsTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let firstLocation = locations.last {
            let currentLocationBusItem = ItemType.busStop(BusStop(name: Constants.Stops.currentLocation,
                                                                  lat: firstLocation.coordinate.latitude,
                                                                  long: firstLocation.coordinate.longitude))
            currentLocationSection = Section(type: .currentLocation, items: [currentLocationBusItem])
            sections = createSections()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("SearchResultsTableVC CLLocationManager didFailWithError: \(error)")
        //this means they dont have location services enabled
        if error._code == CLError.denied.rawValue {
            let currentLocationBusItem = ItemType.busStop(BusStop(name: Constants.Stops.currentLocation,
                                                                  lat: 0.0,
                                                                  long: 0.0))
            currentLocationSection = Section(type: .currentLocation, items: [currentLocationBusItem])
            sections = createSections()
        }
    }
}

// MARK: Navigation Controller Delegate
extension SearchResultsTableViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if returningFromAllStopsTVC, let busStop = returningFromAllStopsBusStop {
            destinationDelegate?.didSelectDestination(busStop: busStop, placeResult: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
