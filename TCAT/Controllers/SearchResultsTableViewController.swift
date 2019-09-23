//
//  SearchResultsTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import Crashlytics
import DZNEmptyDataSet
import FutureNova
import MapKit
import SwiftyJSON
import UIKit

protocol DestinationDelegate: class {
    func didSelectPlace(place: Place)
}

protocol SearchBarCancelDelegate: class {
    func didCancel()
}

class SearchResultsTableViewController: UITableViewController {

    var searchBar: UISearchBar?

    var currentLocation: Place?
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    private weak var destinationDelegate: DestinationDelegate?
    private weak var searchBarCancelDelegate: SearchBarCancelDelegate?

    private var busStops: [Place] = []
    private var favorites: [Place] = []
    private var favoritesSection: Section!
    private var initialTableViewIndexMinY: CGFloat!
    private let locationManager = CLLocationManager()
    private let networking: Networking = URLSession.shared.request
    private var recentLocations: [Place] = []
    private var recentSearchesSection: Section!
    private var returningFromAllStopsBusStop: Place?
    private var returningFromAllStopsTVC = false
    private var searchResultsSection: Section!
    private var seeAllStopsSection: Section!
    private var timer: Timer?

    private var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    convenience init(searchBarCancelDelegate: SearchBarCancelDelegate? = nil, destinationDelegate: DestinationDelegate? = nil) {
        self.init(style: .grouped)

        self.searchBarCancelDelegate = searchBarCancelDelegate
        self.destinationDelegate = destinationDelegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set Up TableView
        tableView.register(GeneralTableViewCell.self, forCellReuseIdentifier: Constants.Cells.generalCellIdentifier)
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: Constants.Cells.placeIdentifier)
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexColor = Colors.primaryText
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = Colors.backgroundWash
        tableView.showsVerticalScrollIndicator = false
        tableView.reloadData()

        // Set Up LocationManager
        locationManager.delegate = self

        // Set Up MKSearchCompleter
        searchCompleter.delegate = self
        if let searchRadius = CLLocationDistance(exactly: Constants.Map.searchRadius) {
            let center = CLLocationCoordinate2D(latitude: Constants.Map.startingLat, longitude: Constants.Map.startingLong)
            searchCompleter.region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: searchRadius,
                longitudinalMeters: searchRadius
            )
        }

        // Fetch RecentLocation and Favorites
        recentLocations = Global.shared.retrievePlaces(for: Constants.UserDefaults.recentSearch)
        favorites = Global.shared.retrievePlaces(for: Constants.UserDefaults.favorites)

        // Set Up Sections For TableView
        seeAllStopsSection = Section.seeAllStops
        recentSearchesSection = Section.recentSearches(items: recentLocations)
        favoritesSection = Section.favorites(items: favorites)
        searchResultsSection = Section.searchResults(items: [])

        createDefaultSections()
        searchBar?.becomeFirstResponder()
        searchBar?.tintColor = Colors.black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar?.tintColor = Colors.primaryText
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestLocation()
    }

    private func createDefaultSections() {
        var sections = [
            favoritesSection,
            recentSearchesSection,
            seeAllStopsSection
            ].filter { !$0.isEmpty }
        if let currentLocation = currentLocation {
            sections.insert(Section.currentLocation(location: currentLocation), at: 0)
        }

        self.sections = sections
    }

    private func updateSearchResultsSection(with searchResults: [Place]) {
        searchResultsSection = Section.searchResults(items: searchResults)
        sections = searchResultsSection.isEmpty ? [] : [self.searchResultsSection]
        if !sections.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    private func showLocationDeniedAlert() {
        let alertController = UIAlertController(title: Constants.Alerts.LocationEnable.title,
                                                message: Constants.Alerts.LocationEnable.message,
                                                preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: Constants.Alerts.LocationEnable.settings, style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                      options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                      completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: Constants.Alerts.LocationEnable.cancel, style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: {
            self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
        })
    }

    private func getSearchResults (searchText: String) -> Future<Response<[Place]>> {
        return networking(Endpoint.getSearchResults(searchText: searchText)).decode()
    }

    @objc private func getPlaces(timer: Timer) {
        if let userInfo = timer.userInfo as? [String: String],
            let searchText = userInfo["searchText"],
            !searchText.isEmpty {
            getAppleSearchResults(searchText: searchText).observe { [weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .value(let response):
                        self.busStops = response.data.busStops
                        if let applePlaces = response.data.applePlaces {
                            let searchResults = applePlaces + self.busStops
                            self.updateSearchResultsSection(with: searchResults)
                        } else {
                            self.searchCompleter.queryFragment = searchText
                        }
                    default: break
                    }
                }
            }
            //            getSearchResults(searchText: searchText).observe { [weak self] result in
            //                guard let `self` = self else { return }
            //                DispatchQueue.main.async {
            //                    switch result {
            //                    case .value(let response):
            //                        self.searchResultsSection = Section.searchResults(items: response.data)
            //                        self.sections = self.searchResultsSection.isEmpty ? [] : [self.searchResultsSection]
            //                        if !self.sections.isEmpty {
            //                            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            //                        }
            //                    default: break
            //                    }
            //                }
            //            }
//            getAppleSearchText(for: searchText)
        } else {
            createDefaultSections()
        }
    }

    private func getAppleSearchResults(searchText: String) -> Future<Response<AppleSearchResponse>> {
        return networking(Endpoint.getAppleSearchResults(searchText: searchText)).decode()
    }

    private func updateApplePlacesCache(searchText: String, places: [Place]) -> Future<Response<Bool>> {
        return networking(Endpoint.updateApplePlacesCache(searchText: searchText, places: places)).decode()
    }

}

extension SearchResultsTableViewController: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print("MKLocalSearch got results: \(completer.results)")
        var places = [Place]()
        let dispatchGroup = DispatchGroup()
        searchResults = completer.results
        searchResults.forEach { (completion) -> Void in
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            dispatchGroup.enter()
            search.start(completionHandler: { (response, error) in
                if error != nil {
                    print("Search Result Error: \(error)")
                }
                if let mapItem = response?.mapItems.first,
                    let name = mapItem.name,
                    let address = mapItem.placemark.thoroughfare,
                    let city = mapItem.placemark.locality,
                    let state = mapItem.placemark.administrativeArea,
                    let country = mapItem.placemark.country {
                    let lat = mapItem.placemark.coordinate.latitude
                    let long = mapItem.placemark.coordinate.longitude
                    let description = [address, city, state, country].joined(separator: ", ")
                    let place = Place(name: name, latitude: lat, longitude: long, placeDescription: description)
                    places.append(place)
                }
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .main) {
            let searchResults = places + self.busStops
            self.updateSearchResultsSection(with: searchResults)
            self.updateApplePlacesCache(searchText: completer.queryFragment, places: places).observe { [weak self] result in
                guard self != nil else { return }
                switch result {
                case .value(let response):
                    print("Succeeded in updating cache BOOL: \(response.data)")
                default: break
                }
            }
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("MKLocalSearch failed for error: \(error)")
    }

}

// MARK: TableView Data Source
extension SearchResultsTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .recentSearches:
            return recentLocations.count
        case .favorites:
            return favorites.count
        default:
            return sections[section].getItems().count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .currentLocation, .seeAllStops:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.generalCellIdentifier) as? GeneralTableViewCell
                else { return UITableViewCell() }
            cell.configure(for: sections[indexPath.section])
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.placeIdentifier) as? PlaceTableViewCell
                else { return UITableViewCell() }
            cell.configure(for: sections[indexPath.section].getItems()[indexPath.row])
            return cell
        }
    }
}

// MARK: TableView Delegate
extension SearchResultsTableViewController {

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header: HeaderView!

        switch sections[section] {
        case .recentSearches:
            header = HeaderView(labelText: Constants.TableHeaders.recentSearches, buttonType: .clear)
        case .favorites:
            header = HeaderView(labelText: Constants.TableHeaders.favoriteDestinations, buttonType: .add)
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
        switch sections[section] {
        case .favorites, .recentSearches: return 50
        default: return 24
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var didSelectAllStops = false
        let allStopsTVC = AllStopsTableViewController(delegate: self)

        if sections[indexPath.section] == .seeAllStops {
            didSelectAllStops = true
        } else {
            let place = sections[indexPath.section].getItems()[indexPath.row]
            if place.latitude == 0.0 && place.longitude == 0.0 {
                showLocationDeniedAlert()
                return
            }
            destinationDelegate?.didSelectPlace(place: place)
        }

        definesPresentationContext = false
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar?.endEditing(true)

        if didSelectAllStops {
            if parent?.isKind(of: UISearchController.self) ?? false {
                let navController = self.parent?.presentingViewController?.navigationController
                navController?.delegate = self
                navController?.pushViewController(allStopsTVC, animated: true)
            }
        }
    }
}

// MARK: ScrollView Delegate
extension SearchResultsTableViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cancelButtonIVar = class_getInstanceVariable(UIButton.self, "_cancelButton"),
            let cancelButton = object_getIvar(searchBar, cancelButtonIVar) as? UIButton {
            cancelButton.isEnabled = true
        }
        //        if let cancelButton = searchBar?.value(forKey: "_cancelButton") as? UIButton {
        //            cancelButton.isEnabled = true
        //        }
    }
}

// MARK: Search Bar Delegate
extension SearchResultsTableViewController: UISearchBarDelegate, UISearchResultsUpdating {

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
        timer = Timer.scheduledTimer(timeInterval: 0.75,
                                     target: self,
                                     selector: #selector(getPlaces),
                                     userInfo: ["searchText": searchText],
                                     repeats: false)
    }
}

extension SearchResultsTableViewController: UnwindAllStopsTVCDelegate {
    func dismissSearchResultsVC(place: Place) {
        returningFromAllStopsBusStop = place
        returningFromAllStopsTVC = true
    }
}

// MARK: - Location Manager Delegates
extension SearchResultsTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = Place(name: Constants.General.currentLocation,
                                    latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude)
            createDefaultSections()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("SearchResultsTableVC CLLocationManager didFailWithError: \(error)")
        // This means they dont have location services enabled. We catch this.
        if error._code == CLError.denied.rawValue {
            currentLocation = nil
            createDefaultSections()
        }
    }
}

// MARK: Navigation Controller Delegate
extension SearchResultsTableViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if returningFromAllStopsTVC, let place = returningFromAllStopsBusStop {
            destinationDelegate?.didSelectPlace(place: place)
        }
    }
}

/// MARK: DZNEmptyDataSet DataSource

// To be eventually removed and replaced with recent searches
extension SearchResultsTableViewController: DZNEmptyDataSetSource {
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -80
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "emptyPin")
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: Constants.EmptyStateMessages.locationNotFound,
                                  attributes: [.foregroundColor: Colors.metadataIcon])
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
