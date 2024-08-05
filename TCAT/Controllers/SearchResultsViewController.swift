//
//  SearchResultsViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import DZNEmptyDataSet
import FutureNova
import MapKit
import SwiftyJSON
import UIKit

protocol DestinationDelegate: AnyObject {
    func didSelectPlace(place: Place)
}

protocol SearchBarCancelDelegate: AnyObject {
    func didCancel()
}

class SearchResultsViewController: UIViewController {

    var searchBar: UISearchBar?
    var tableView: UITableView!

    var currentLocation: Place?
    private weak var destinationDelegate: DestinationDelegate?
    private weak var searchBarCancelDelegate: SearchBarCancelDelegate?

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

    init(searchBarCancelDelegate: SearchBarCancelDelegate? = nil, destinationDelegate: DestinationDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.searchBarCancelDelegate = searchBarCancelDelegate
        self.destinationDelegate = destinationDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set Up TableView
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(GeneralTableViewCell.self, forCellReuseIdentifier: Constants.Cells.generalCellIdentifier)
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: Constants.Cells.placeIdentifier)
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexColor = Colors.primaryText
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = Colors.backgroundWash
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Set Up LocationManager
        locationManager.delegate = self

        // Fetch recent location
        recentLocations = Global.shared.retrievePlaces(for: Constants.UserDefaults.recentSearch)

        // Set Up Sections For TableView
        seeAllStopsSection = Section.seeAllStops
        recentSearchesSection = Section.recentSearches(items: recentLocations)
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
        let alertController = UIAlertController(
            title: Constants.Alerts.LocationEnable.title,
            message: Constants.Alerts.LocationEnable.message,
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: Constants.Alerts.LocationEnable.settings, style: .default) { _ in
            UIApplication.shared.open(
                URL(string: UIApplication.openSettingsURLString)!,
                options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                completionHandler: nil
            )
        }
        let cancelAction = UIAlertAction(title: Constants.Alerts.LocationEnable.cancel, style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: {
            self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
        })
    }

    @objc private func getPlaces(timer: Timer) {
        print("here")
        if let userInfo = timer.userInfo as? [String: String],
            let searchText = userInfo["searchText"],
            !searchText.isEmpty {
            SearchManager.shared.performLookup(for: searchText) { [weak self] (searchResults, error) in
                guard let self = self else { return }
                if let error = error {
                    self.printClass(context: "SearchManager lookup error", message: error.localizedDescription)
                    return
                }
                DispatchQueue.main.async {
                    self.updateSearchResultsSection(with: searchResults)
                }
            }
        } else {
            createDefaultSections()
        }
    }

}

// MARK: - TableView Data Source
extension SearchResultsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .recentSearches:
            return recentLocations.count
        default:
            return sections[section].getItems().count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .currentLocation, .seeAllStops:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.Cells.generalCellIdentifier
            ) as? GeneralTableViewCell else { return UITableViewCell() }
            cell.configure(for: sections[indexPath.section])
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.Cells.placeIdentifier
            ) as? PlaceTableViewCell else { return UITableViewCell() }
            cell.configure(for: sections[indexPath.section].getItems()[indexPath.row])
            return cell
        }
    }

}

// MARK: - TableView Delegate
extension SearchResultsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header: HeaderView?

        switch sections[section] {
        case .recentSearches:
            header = HeaderView(labelText: Constants.TableHeaders.recentSearches, buttonType: .clear)
        case .seeAllStops, .searchResults:
            return nil
        default:
            break
        }

        return header
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section] {
        case .recentSearches: return 50
        default: return 24
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var didSelectAllStops = false
        let stopPicker = StopPickerViewController()
        stopPicker.onSelection = { place in
            self.returningFromAllStopsBusStop = place
            self.returningFromAllStopsTVC = true
            self.navigationController?.popViewController(animated: true) // pop the StopPicker
        }

        if sections[indexPath.section] == .seeAllStops {
            didSelectAllStops = true
        } else {
            if let searchBar = searchBar,
                let searchText = searchBar.text {
                let payload = SearchResultSelectedPayload(
                    searchText: searchText,
                    selectedIndex: indexPath.row,
                    totalResults: sections[indexPath.section].getItems().count
                )
                TransitAnalytics.shared.log(payload)
            }
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
                navController?.pushViewController(stopPicker, animated: true)
            }
        }
    }
}

// MARK: - ScrollView Delegate
extension SearchResultsViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cancelButtonIVar = class_getInstanceVariable(UIButton.self, "_cancelButton"),
            let cancelButton = object_getIvar(searchBar, cancelButtonIVar) as? UIButton {
            cancelButton.isEnabled = true
        }
    }

}

// MARK: - Search Bar Delegate
extension SearchResultsViewController: UISearchBarDelegate, UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        if !sections.isEmpty && tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        searchController.searchResultsController?.view.isHidden = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelDelegate?.didCancel()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.75,
            target: self,
            selector: #selector(getPlaces),
            userInfo: ["searchText": searchText],
            repeats: false
        )
    }

}

// MARK: - Location Manager Delegates
extension SearchResultsViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = Place(
                name: Constants.General.currentLocation,
                type: .currentLocation,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            createDefaultSections()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        printClass(context: "CLLocationManager didFailWithError", message: error.localizedDescription)
        // This means they dont have location services enabled. We catch this.
        if error._code == CLError.denied.rawValue {
            currentLocation = nil
            createDefaultSections()
        }
    }

}

// MARK: - Navigation Controller Delegate
extension SearchResultsViewController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        if returningFromAllStopsTVC, let place = returningFromAllStopsBusStop {
            destinationDelegate?.didSelectPlace(place: place)
        }
    }

}

// MARK: - DZNEmptyDataSet DataSource
// To be eventually removed and replaced with recent searches
extension SearchResultsViewController: DZNEmptyDataSetSource {
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -80
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "emptyPin")
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(
            string: Constants.EmptyStateMessages.locationNotFound,
            attributes: [.foregroundColor: Colors.metadataIcon]
        )
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(
    _ input: [String: Any]
) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in
        (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)
    })
}
