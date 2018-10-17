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
import WhatsNewKit

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
    var tableView: HomeTableView!
    var initialTableViewIndexMidY: CGFloat!
    var searchBar: UISearchBar!
    let infoButton = UIButton(type: .infoLight)
    var whatsNewView: WhatsNewHeaderView!
    var recentLocations: [ItemType] = []
    var favorites: [ItemType] = []
    var isKeyboardVisible = false
    var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
            if sections.isEmpty {
                tableView.tableHeaderView = nil
            }
        }
    }
    var loadingIndicator: LoadingIndicator?
    var isLoading: Bool { return loadingIndicator != nil }

    let reachability = Reachability(hostname: Network.ipAddress)

    var banner: StatusBarNotificationBanner? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
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

        tableView = HomeTableView(frame: .zero, style: .grouped)
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

            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview().offset(view.layoutMargins.top)
            }
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

        if !VersionStore().has(version: WhatsNew.Version.current()) {
            createWhatsNewView()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(_:)),
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
        return banner != nil ? .lightContent : .default
    }

    @objc func reachabilityChanged(_ notification: Notification) {
        guard let reachability = notification.object as? Reachability else {
            return
        }

        // Dismiss current banner, if any
        banner?.dismiss()
        banner = nil

        // Dismiss current loading indicator, if any
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil

        switch reachability.connection {
        case .none:
            banner = StatusBarNotificationBanner(title: Constants.Banner.noInternetConnection, style: .danger)
            banner?.autoDismiss = false
            banner?.show(queuePosition: .front, on: navigationController)
            self.isNetworkDown = true
            self.sectionIndexes = [:]
            self.searchBar.isUserInteractionEnabled = false
            self.sections = []
        case .cellular, .wifi:
            self.isNetworkDown = false
            sections = createSections()
            self.searchBar.isUserInteractionEnabled = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)

        // Remove banner
        banner?.dismiss()
        banner = nil

        // Remove activity indicator
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recentLocations = SearchTableViewManager.shared.retrieveRecentPlaces(for: Constants.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrieveRecentPlaces(for: Constants.UserDefaults.favorites)
        if !isNetworkDown {
            sections = createSections()
        }
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

    func createWhatsNewView() {
        whatsNewView = WhatsNewHeaderView(updateName: "App Shortcuts for Favorites",
                                          description: "Force Touch the app icon to search your favorites even faster.")
        whatsNewView.whatsNewDelegate = self
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.addSubview(whatsNewView)
        whatsNewView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(whatsNewView.containerPadding)
        }

        tableView.tableHeaderView = containerView
        containerView.snp.makeConstraints { (make) in
            make.top.centerX.width.equalToSuperview()
        }
    }

    /* Keyboard Functions */
    @objc func keyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
        searchBarCancelButtonClicked(searchBar)
    }

    /* ScrollView Delegate */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let searchBar = searchBar, let cancelButton = searchBar.value(forKey: "_cancelButton") as? UIButton {
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

        cell.textLabel?.font = .style(Fonts.System.regular, size: 14)
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
        if !whatsNewView.isHidden && tableView.tableHeaderView != nil {
            dismissCardTemp()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.placeholder = Constants.Phrases.searchPlaceholder
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        searchBar.text = nil

        let submitBugBarButton = UIBarButtonItem(customView: infoButton)
        navigationItem.setRightBarButton(submitBugBarButton, animated: false)
        sections = createSections()
        if whatsNewView.isHidden && tableView.tableHeaderView != nil {
            unHideCard()
        }
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
        // If tableview header is hidden, increase offset to center EmptyDataSet view
        return tableView.tableHeaderView == nil ? -80 : (-80 - tableView.contentInset.top)
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        // If loading indicator is being shown, don't display image
        if isLoading {
            return nil
        } else {
            return isNetworkDown ? #imageLiteral(resourceName: "noWifi") : #imageLiteral(resourceName: "noRoutes")
        }

    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        // If loading indicator is being shown, don't display description
        if isLoading {
            return nil
        } else {
            let title = isNetworkDown ? "No Network Connection" : "Location Not Found"
            return NSAttributedString(string: title, attributes: [.foregroundColor : UIColor.mediumGrayColor])
        }
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        // If loading indicator is being shown, don't display button
        if isLoading {
            return nil
        } else {
            let title = "Retry"
            return NSAttributedString(string: title, attributes: [.foregroundColor : UIColor.tcatBlueColor])
        }
    }

    func setUpLoadingIndicator() {
        loadingIndicator = LoadingIndicator()
        if let loadingIndicator = loadingIndicator {
            view.addSubview(loadingIndicator)
            loadingIndicator.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.height.equalTo(40)
            }
        }
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTap didTapButton: UIButton) {
        setUpLoadingIndicator()
        if isLoading {
            tableView.reloadData()

            // Have loading indicator time out after one second
            let delay = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                // if the empty state is the "Location Not Found" state, clear the text in the search bar
                if !self.isNetworkDown {
                    self.searchBar.text = nil
                    self.searchBar.placeholder = Constants.Phrases.searchPlaceholder
                }
                self.loadingIndicator?.removeFromSuperview()
                self.loadingIndicator = nil
                self.tableView.reloadData()
            }
        }
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

// MARK: WhatsNew Delegate
extension HomeViewController: WhatsNewDelegate {

    func okButtonPressed() {
        userDefaults.set(true, forKey: Constants.UserDefaults.whatsNewDismissed)
        tableView.beginUpdates()
        tableView.animating = true
        UIView.animate(withDuration: 0.35, animations: {
            if let containerView = self.tableView.tableHeaderView {
                self.tableView.contentInset = .init(top: -36, left: 0, bottom: 0, right: 0)
                containerView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01).translatedBy(x: 0, y: -6000)
            }
        }, completion: {(completed) in
            if completed {
                self.tableView.animating = false
                self.tableView.tableHeaderView = nil
            }
        })
        tableView.endUpdates()
    }

    /// Hide card when user is searching for Bus Stops
    func hideCard() {
        UIView.animate(withDuration: 0.35, animations: {
            self.tableView.contentInset = .init(top: -whatsNewView.frame.height - 20, left: 0, bottom: 0, right: 0)
            self.whatsNewView.alpha = 0
            for subview in whatsNewView.subviews {
                subview.alpha = 0
            }
        }) { (completed) in
            self.whatsNewView.isHidden = true
        }
    }

    /// Present card after user is done searching
    func showCard() {
        UIView.animate(withDuration: 0.35, animations: {
            self.tableView.contentInset = .zero
            self.tableView.contentOffset = .zero
            self.whatsNewView.alpha = 1
            for subview in whatsNewView.subviews {
                subview.alpha = 1
            }
        }) { (completed) in
            self.whatsNewView.isHidden = false
        }
    }

    func cardPressed() {
        print("Card Pressed")
    }
}

// MARK: Custom TableView
class HomeTableView: UITableView {
    var animating = false
    override var tableHeaderView: UIView? {
        didSet {
            if !animating {
                if tableHeaderView == nil {
                    self.contentInset = .init(top: -36, left: 0, bottom: 0, right: 0)
                } else {
                    self.contentInset = .zero
                }
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
