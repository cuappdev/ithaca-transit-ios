//
//  HomeViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 2/8/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import GooglePlaces
import SwiftyJSON
import Alamofire
import DZNEmptyDataSet
import NotificationBannerSwift
import Crashlytics
import SafariServices
import SnapKit

class HomeViewController: UIViewController {

    let userDefaults = UserDefaults.standard
    let cornellDestinations = [(name: "North Campus", stops: "RPCC, Balch Hall, Appel, Helen Newman, Jessup Field"),
                               (name: "West Campus", stops: "Baker Flagpole, Baker Flagpole (Slopeside)"),
                               (name: "Central Campus", stops: "Statler Hall, Uris Hall, Goldwin Smith Hall"),
                               (name: "Collegetown", stops: "Collegetown Crossing, Schwartz Center"),
                               (name: "Ithaca Commons", stops: "Albany @ Salvation Army, State Street, Lot 32")]

    var locationManager = CLLocationManager()
    var timer: Timer?
    var isNetworkDown = false
    var searchResultsSection: Section!
    var sectionIndexes: [String: Int]! = [:]
    var tableView: UITableView!
    var initialTableViewIndexMidY: CGFloat!
    var searchBar: UISearchBar!
    let infoButton = UIButton(type: .infoLight)
    var recentLocations: [ItemType] = []
    var favorites: [ItemType] = []
    var isKeyboardVisible = false
    var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    let reachability = Reachability(hostname: Network.ipAddress)
    var isBannerShown = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    var banner: StatusBarNotificationBanner?

    func tctSectionHeaderFont() -> UIFont? {
        return .style(Fonts.System.regular, size: 14)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add Notification Observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        recentLocations = SearchTableViewManager.shared.retrieveRecentPlaces(for: Constants.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrieveRecentPlaces(for: Constants.UserDefaults.favorites)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        view.backgroundColor = .tableBackgroundColor

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        tableView.separatorColor = .lineDotColor
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BusStopCell.self, forCellReuseIdentifier: Constants.Cells.busIdentifier)
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: Constants.Cells.searchResultsIdentifier)
        tableView.register(CornellDestinationCell.self, forCellReuseIdentifier: Constants.Cells.cornellDestinationsIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cells.seeAllStopsIdentifier)
        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo((navigationController?.navigationBar.bounds.maxY)!)
        }

        searchBar = UISearchBar()
        searchBar.placeholder = Constants.Phrases.searchPlaceholder
        searchBar.delegate = self
        searchBar.searchBarStyle = .default
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = .tableBackgroundColor
        navigationItem.titleView = searchBar

        let rightBarButton = UIBarButtonItem(customView: infoButton)
        navigationItem.setRightBarButton(rightBarButton, animated: true)
        infoButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0)
        infoButton.contentVerticalAlignment = .center
        infoButton.addTarget(self, action: #selector(openInformationScreen), for: .touchUpInside)
        infoButton.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(38)
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(note:)),
                                               name: .reachabilityChanged,
                                               object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("HomeVC viewDidLayoutSubviews: Could not start reachability notifier")
        }
        if searchBar.showsCancelButton {
            searchBar.becomeFirstResponder()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isBannerShown ? .lightContent : .default
    }

    @objc func reachabilityChanged(note: Notification) {
        if let reachability = note.object as? Reachability {
            switch reachability.connection {
            case .none:
                if !isBannerShown {
                    banner = StatusBarNotificationBanner(title: Constants.Banner.noInternetConnection, style: .danger)
                    banner!.autoDismiss = false
                    banner!.show(queuePosition: .front, on: navigationController)
                    isBannerShown = true
                }
                self.isNetworkDown = true
                self.sectionIndexes = [:]
                self.searchBar.isUserInteractionEnabled = false
                self.sections = []
            case .cellular, .wifi:
                if isBannerShown {
                    banner?.dismiss()
                    banner = nil
                    isBannerShown = false
                }
                sections = createSections()
                self.searchBar.isUserInteractionEnabled = true
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recentLocations = SearchTableViewManager.shared.retrieveRecentPlaces(for: Constants.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrieveRecentPlaces(for: Constants.UserDefaults.favorites)
        sections = createSections()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        StoreReviewHelper.checkAndAskForReview()

    }

    func createSections() -> [Section] {
        var allSections: [Section] = []
        let recentSearchesSection = Section(type: .recentSearches, items: recentLocations)
        let seeAllStopsSection = Section(type: .seeAllStops, items: [.seeAllStops])
        var favoritesSection = Section(type: .favorites, items: favorites)
        if favoritesSection.items.isEmpty {
            let addFavorites = BusStop(name: Constants.Phrases.firstFavorite, lat: 0.0, long: 0.0)
            favoritesSection = Section(type: .favorites, items: [.busStop(addFavorites)])
        }
        allSections.append(favoritesSection)
        allSections.append(recentSearchesSection)
        allSections.append(seeAllStopsSection)
        return allSections.filter { !$0.items.isEmpty }
    }

    @objc func presentFavoritesTVC(sender: UIButton? = nil) {
        let favoritesTVC = FavoritesTableViewController()
        let navController = CustomNavigationController(rootViewController: favoritesTVC)
        present(navController, animated: true, completion: nil)
    }

    /* Keyboard Functions */
    @objc func keyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
    }

    /* ScrollView Delegate */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cancelButton = searchBar.value(forKey: "_cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }

    /* Get Search Results */
    @objc func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if !searchText.isEmpty {
            Network.getGooglePlacesAutocompleteResults(searchText: searchText).perform(withSuccess: { responseJson in
                self.searchResultsSection = SearchTableViewManager.shared.parseGoogleJSON(searchText: searchText, json: responseJson)
                self.tableView.contentOffset = .zero
                self.sections = [self.searchResultsSection]
            })
        } else {
            sections = createSections()
        }
    }

    /* Open information screen */
    @objc func openInformationScreen() {
        let informationViewController = InformationViewController()
        let navigationVC = CustomNavigationController(rootViewController: informationViewController)
        present(navigationVC, animated: true)
    }
}

// MARK: TableView DataSource
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && !favorites.isEmpty
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var itemType: ItemType?
        var cell: UITableViewCell!
        switch sections[indexPath.section].type {
        case .cornellDestination:
            itemType = .cornellDestination
        case .recentSearches, .seeAllStops, .searchResults, .favorites:
            itemType = sections[indexPath.section].items[indexPath.row]
        default: break
        }

        if let itemType = itemType {
            switch itemType {
            case .busStop(let busStop):
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.busIdentifier) as? BusStopCell
                cell.textLabel?.text = busStop.name
            case .placeResult(let placeResult):
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.searchResultsIdentifier) as? SearchResultsCell
                cell.textLabel?.text = placeResult.name
                cell.detailTextLabel?.text = placeResult.detail
            case .cornellDestination:
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.cornellDestinationsIdentifier) as? CornellDestinationCell
                cell.textLabel?.text = cornellDestinations[indexPath.row].name
                cell.detailTextLabel?.text = cornellDestinations[indexPath.row].stops
            case .seeAllStops:
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.seeAllStopsIdentifier)
                cell.textLabel?.text = "See All Stops"
                cell.imageView?.image = #imageLiteral(resourceName: "list")
                cell.accessoryType = .disclosureIndicator
            }
        }

        cell.textLabel?.font = tctSectionHeaderFont()
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.layoutSubviews()

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section].type {
        case .cornellDestination: return cornellDestinations.count
        case .recentSearches: return recentLocations.count
        case .favorites: return favorites.isEmpty ? 1 : favorites.count
        case .seeAllStops, .searchResults: return sections[section].items.count
        default: return 0
        }
    }
}

// MARK: TableView Delegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderView()

        switch sections[section].type {
        case .cornellDestination:
            header.setupView(labelText: "Get There Now", displayAddButton: false)
        case .recentSearches:
            header.setupView(labelText: "Recent Searches", displayAddButton: false)
        case .favorites:
            header.setupView(labelText: "Favorite Destinations", displayAddButton: true)
            header.addFavoritesDelegate = self
        case .seeAllStops, .searchResults:
            return nil
        default: break
        }

        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section].type {
        case .favorites, .recentSearches: return 50
        default: return 24
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemTypeToDelete = sections[indexPath.section].items[indexPath.row]
            switch itemTypeToDelete {
            case .busStop(let busStop):
                favorites = SearchTableViewManager.shared.deleteFavorite(favorite: busStop, allFavorites: favorites)
            case .placeResult(let placeResult):
                favorites = SearchTableViewManager.shared.deleteFavorite(favorite: placeResult, allFavorites: favorites)
            default: break
            }
            sections = createSections()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var itemType: ItemType
        let optionsVC = RouteOptionsViewController()
        let allStopsTVC = AllStopsTableViewController()
        var didSelectAllStops = false
        var presentOptionsVC = true

        switch sections[indexPath.section].type {
        case .cornellDestination:
            itemType = .cornellDestination
        case .recentSearches, .searchResults, .seeAllStops, .favorites:
            itemType = sections[indexPath.section].items[indexPath.row]
        default: itemType = ItemType.cornellDestination
        }
        switch itemType {
        case .cornellDestination:
            print("User Selected Cornell Destination")
        case .seeAllStops:
            didSelectAllStops = true
            allStopsTVC.allStops = SearchTableViewManager.shared.getAllStops()
        case .busStop(let busStop):
            if busStop.name == Constants.Phrases.firstFavorite {
                presentOptionsVC = false
                presentFavoritesTVC()
            } else {
                SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.recentSearch, location: busStop, limit: 8)
                optionsVC.searchTo = busStop
            }
        case .placeResult(let placeResult):
            SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.recentSearch, location: placeResult, limit: 8)
            optionsVC.searchTo = placeResult
        }

        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.endEditing(true)
        let vcToPush = didSelectAllStops ? allStopsTVC : optionsVC
        if presentOptionsVC {
            navigationController?.pushViewController(vcToPush, animated: true)
        }

    }
}

// MARK: Search Bar Delegate
extension HomeViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.placeholder = nil
        navigationItem.rightBarButtonItem = nil
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.placeholder = Constants.Phrases.searchPlaceholder
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        searchBar.text = nil

        let submitBugBarButton = UIBarButtonItem(customView: infoButton)
        navigationItem.setRightBarButton(submitBugBarButton, animated: false)
        sections = createSections()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(getPlaces), userInfo: ["searchText": searchText], repeats: false)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

// MARK: Location Delegate
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        if status == .denied {
            let alertTitle = "Location Services Disabled"
            let alertMessage = "The app won't be able to use your current location without permission. Tap Settings to turn on Location Services."
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }

            guard let showReminder = userDefaults.value(forKey: Constants.UserDefaults.showLocationAuthReminder) as? Bool else {

                userDefaults.set(true, forKey: Constants.UserDefaults.showLocationAuthReminder)

                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)

                alertController.addAction(settingsAction)
                alertController.preferredAction = settingsAction

                present(alertController, animated: true)

                return
            }

            if !showReminder {
                return
            }

            let dontRemindAgainAction = UIAlertAction(title: "Don't Remind Me Again", style: .default) { (_) in
                self.userDefaults.set(false, forKey: Constants.UserDefaults.showLocationAuthReminder)
            }
            alertController.addAction(dontRemindAgainAction)

            alertController.addAction(settingsAction)
            alertController.preferredAction = settingsAction

            present(alertController, animated: true)

        }
    }
}

// MARK: DZN Empty Data Set Source
extension HomeViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -80
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return isNetworkDown ? #imageLiteral(resourceName: "noInternet") : #imageLiteral(resourceName: "emptyPin")
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = isNetworkDown ? "No Network Connection" : "Location Not Found"
        return NSAttributedString(string: title, attributes: [.foregroundColor : UIColor.mediumGrayColor])
    }
}

// MARK: AddFavorites Delegate
extension HomeViewController: AddFavoritesDelegate {
    func displayFavoritesTVC() {
        if favorites.count < 5 {
            presentFavoritesTVC()
        } else {
            let title = "Maximum Number of Favorites"
            let message = "To add more favorites, please swipe left and delete one first."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let done = UIAlertAction(title: "Got It!", style: .default)
            alertController.addAction(done)
            present(alertController, animated: true, completion: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
