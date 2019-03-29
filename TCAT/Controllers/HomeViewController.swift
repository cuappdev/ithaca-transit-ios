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

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var timer: Timer?
    var isNetworkDown = false
    var firstViewing = true
    var searchResultsSection: Section!
    var sectionIndexes: [String: Int]! = [:]
    var tableView: UITableView!
    var initialTableViewIndexMidY: CGFloat!
    var searchBar: UISearchBar!
    let infoButton = UIButton(type: .infoLight)
    var whatsNewView: WhatsNewHeaderView!
    var whatsNewContainerView: UIView!
    var recentLocations: [Place] = []
    var favorites: [Place] = []
    var isKeyboardVisible = false
    var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
            if sections.isEmpty {
                tableView.tableHeaderView = .zero
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
        
        updatePlaces()
        
        // Add Notification Observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        navigationController?.navigationBar.barTintColor = Colors.white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Colors.white]
        view.backgroundColor = Colors.backgroundWash

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        tableView.separatorColor = Colors.dividerTextField
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: Constants.Cells.placeIdentifier)
        tableView.register(GeneralTableViewCell.self, forCellReuseIdentifier: Constants.Cells.seeAllStopsIdentifier)
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
        searchBar.placeholder = Constants.General.searchPlaceholder
        searchBar.delegate = self
        searchBar.searchBarStyle = .default
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = Colors.backgroundWash
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

        showWhatsNewCardIfNeeded()
        
        // Set Version
        VersionStore.shared.set(version: WhatsNew.Version.current())
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

        // Dismiss current banner or loading indicator, if any
        banner?.dismiss()
        banner = nil
        removeLoadingIndicator()

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

        // Remove banner and loading indicator
        banner?.dismiss()
        banner = nil
        removeLoadingIndicator()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePlaces()
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
    
    func updatePlaces() {
        recentLocations = SearchTableViewManager.shared.retrievePlaces(for: Constants.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrievePlaces(for: Constants.UserDefaults.favorites)
    }

    func createSections() -> [Section] {
        var allSections: [Section] = []
        let recentSearchesSection = Section(type: .recentSearches, items: recentLocations)
        let seeAllStopsSection = Section(type: .seeAllStops, items: [])
        var favoritesSection = Section(type: .favorites, items: favorites)
        if favoritesSection.items.isEmpty {
            let addFavorites = Place(
                name: Constants.General.firstFavorite,
                placeDescription: Constants.General.tapHere,
                placeIdentifier: "dummy_data"
            )
            addFavorites.type = .busStop // Special exception to make pin blue for favorite!
            favoritesSection = Section(type: .favorites, items: [addFavorites])
        }
        allSections.append(favoritesSection)
        allSections.append(recentSearchesSection)
        allSections.append(seeAllStopsSection)
        return allSections.filter { !$0.items.isEmpty || $0.type == .seeAllStops }
    }

    @objc func presentFavoritesTVC(sender: UIButton? = nil) {
        let favoritesTVC = FavoritesTableViewController()
        let navController = CustomNavigationController(rootViewController: favoritesTVC)
        present(navController, animated: true, completion: nil)
    }

    func createWhatsNewView(from card: WhatsNewCard, hasPromotion: Bool) {
        whatsNewView = WhatsNewHeaderView(card: card, isPromotion: hasPromotion)
        whatsNewView.whatsNewDelegate = self
        whatsNewContainerView = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: whatsNewView.calculateCardHeight() + whatsNewView.containerPadding.top + whatsNewView.containerPadding.bottom))
        whatsNewContainerView.addSubview(whatsNewView)
        whatsNewView.snp.makeConstraints { (make) in
            let widthPadding = whatsNewView.containerPadding.left + whatsNewView.containerPadding.right
            make.width.equalToSuperview().offset(-widthPadding)
            make.top.leading.bottom.equalToSuperview().inset(whatsNewView.containerPadding)
        }
        tableView.tableHeaderView = whatsNewContainerView
    }
    
    func showWhatsNewCardIfNeeded() {
        
        if VersionStore.shared.isNewCardAvailable() {
            userDefaults.set(false, forKey: Constants.UserDefaults.whatsNewDismissed)
        }

        let promotionCardDismissed = userDefaults.bool(forKey: Constants.UserDefaults.promotionDismissed)
        let whatsNewDismissed = userDefaults.bool(forKey: Constants.UserDefaults.whatsNewDismissed)
        
        let showPromotionalCard = WhatsNewCard.isPromotionActive() && !promotionCardDismissed
        
        firstViewing = userDefaults.value(forKey: Constants.UserDefaults.version) == nil

        // Not the first time loading the app AND there's a new card to show OR the card hasn't been dismissed.
        let showTypicalFeatureCard = !firstViewing && (VersionStore.shared.isNewCardAvailable() || !whatsNewDismissed)
        
        if showPromotionalCard {
            createWhatsNewView(from: WhatsNewCard.promotion, hasPromotion: true)
        }
        else if showTypicalFeatureCard {
            createWhatsNewView(from: WhatsNewCard.newFeature, hasPromotion: false)
        }
        
        if !WhatsNewCard.isPromotionActive() {
            userDefaults.set(false, forKey: Constants.UserDefaults.promotionDismissed)
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
            Network.getSearchResults(searchText: searchText).perform(withSuccess: { response in
                self.searchResultsSection = Section(type: .searchResults, items: response.data)
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
    
    var loadingView = UIView()
    
    /// Show a temporary loading screen
    func showLoadingScreen() {
        
        loadingView.backgroundColor = Colors.backgroundWash
        view.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        let indicator = LoadingIndicator()
        loadingView.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
    }
    
    func removeLoadingScreen() {
        loadingView.removeFromSuperview()
        viewWillAppear(false)
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
        
        var cell: UITableViewCell!
        
        if sections[indexPath.section].type == .seeAllStops {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.seeAllStopsIdentifier) as? GeneralTableViewCell
        }
        
        // Favorites (including Add First Favorite!), Recent Searches
        else {
            guard let placeCell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.placeIdentifier) as? PlaceTableViewCell
                else { return cell }
            placeCell.place = sections[indexPath.section].items[indexPath.row]
            cell = placeCell
        }

        cell.layoutSubviews()

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section].type {
        case .seeAllStops: return 1
        case .recentSearches: return recentLocations.count
        case .favorites: return favorites.isEmpty ? 1 : favorites.count
        case .searchResults: return sections[section].items.count
        default: return 0
        }
    }
}

// MARK: TableView Delegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderView()

        switch sections[section].type {
        case .recentSearches:
            header.setupView(labelText: Constants.TableHeaders.recentSearches, buttonType: .clear)
        case .favorites:
            header.setupView(labelText: Constants.TableHeaders.favoriteDestinations, buttonType: .add)
            header.headerViewDelegate = self
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
            let place = sections[indexPath.section].items[indexPath.row]
            favorites = SearchTableViewManager.shared.deleteFavorite(favorite: place, allFavorites: favorites)
            sections = createSections()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let routeOptionsViewController = RouteOptionsViewController()
        routeOptionsViewController.didReceiveCurrentLocation(currentLocation)
        let allStopsTableViewConroller = AllStopsTableViewController()
        var didSelectAllStops = false
        var shouldPushViewController = true
        
        if sections[indexPath.section].type == .seeAllStops {
            didSelectAllStops = true
            allStopsTableViewConroller.allStops = SearchTableViewManager.shared.getAllStops()
        }
        
        else {
            let place = sections[indexPath.section].items[indexPath.row]
            if place.name == Constants.General.firstFavorite {
                shouldPushViewController = false
                presentFavoritesTVC()
            } else {
                routeOptionsViewController.searchTo = place
                SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.recentSearch, place: place)
                routeOptionsViewController.didSelectPlace(place: place)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.endEditing(true)
        
        let vcToPush = didSelectAllStops ? allStopsTableViewConroller : routeOptionsViewController
        if shouldPushViewController {
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
        if tableView?.tableHeaderView != .zero {
            hideCard()
        }

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.placeholder = Constants.General.searchPlaceholder
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        searchBar.text = nil

        let submitBugBarButton = UIBarButtonItem(customView: infoButton)
        navigationItem.setRightBarButton(submitBugBarButton, animated: false)
        sections = createSections()
        if tableView?.tableHeaderView != .zero {
            showCard()
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
            let alertTitle = Constants.Alerts.LocationDisabled.title
            let alertMessage = Constants.Alerts.LocationDisabled.message
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: Constants.Alerts.LocationDisabled.settings, style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }

            guard let showReminder = userDefaults.value(forKey: Constants.UserDefaults.showLocationAuthReminder) as? Bool else {
                userDefaults.set(true, forKey: Constants.UserDefaults.showLocationAuthReminder)
                let cancelAction = UIAlertAction(title: Constants.Alerts.LocationDisabled.cancel, style: .default, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                alertController.preferredAction = settingsAction
                present(alertController, animated: true)
                return
            }

            if !showReminder {
                return
            }

            let dontRemindAgainAction = UIAlertAction(title: Constants.Alerts.LocationDisabled.cancel, style: .default) { _ in
                self.userDefaults.set(false, forKey: Constants.UserDefaults.showLocationAuthReminder)
            }
            alertController.addAction(dontRemindAgainAction)

            alertController.addAction(settingsAction)
            alertController.preferredAction = settingsAction

            present(alertController, animated: true)

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }
    
}

// MARK: DZN Empty Data Set Source
extension HomeViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        // If tableview header is hidden, increase offset to center EmptyDataSet view
        return tableView.tableHeaderView == nil ? -80 : (-80 - tableView.contentInset.top)
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        // If loading indicator is being shown, don't display image
        if isLoading { return nil }
        return isNetworkDown ? #imageLiteral(resourceName: "noWifi") : #imageLiteral(resourceName: "noRoutes")
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        // If loading indicator is being shown, don't display description
        if isLoading { return nil }
        let title = isNetworkDown ? Constants.EmptyStateMessages.noNetworkConnection: Constants.EmptyStateMessages.locationNotFound
        return NSAttributedString(string: title, attributes: [.foregroundColor: Colors.metadataIcon])
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        // If loading indicator is being shown, don't display button
        if isLoading { return nil }
        let title = Constants.Buttons.retry
        return NSAttributedString(string: title, attributes: [.foregroundColor: Colors.tcatBlue])
    }

    func setupLoadingIndicator() {
        loadingIndicator = LoadingIndicator()
        if let loadingIndicator = loadingIndicator {
            view.addSubview(loadingIndicator)
            loadingIndicator.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.height.equalTo(40)
            }
        }
    }
    
    func removeLoadingIndicator() {
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTap didTapButton: UIButton) {
        setupLoadingIndicator()
        if isLoading {
            tableView.reloadData()

            // Have loading indicator time out after one second
            let delay = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                // if the empty state is the "Location Not Found" state, clear the text in the search bar
                if !self.isNetworkDown {
                    self.searchBar.text = nil
                    self.searchBar.placeholder = Constants.General.searchPlaceholder
                }
                self.removeLoadingIndicator()
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: AddFavorites Delegate
extension HomeViewController: HeaderViewDelegate {
    func clearRecentSearches() {
        
    }
    

    func displayFavoritesTVC() {
        if favorites.count < 5 {
            presentFavoritesTVC()
        } else {
            let title = Constants.Alerts.MaxFavorites.title
            let message = Constants.Alerts.MaxFavorites.message
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let done = UIAlertAction(title: Constants.Alerts.MaxFavorites.action, style: .default)
            alertController.addAction(done)
            present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: WhatsNew Delegate
extension HomeViewController: WhatsNewDelegate {
    
    func getCurrentHomeViewController() -> HomeViewController {
        return self
    }
    
    func dismissView(card: WhatsNewCard) {
        
        if card.isEqual(to: WhatsNewCard.promotion) {
            userDefaults.set(true, forKey: Constants.UserDefaults.promotionDismissed)
        } else if card.isEqual(to: WhatsNewCard.newFeature) {
            userDefaults.set(true, forKey: Constants.UserDefaults.whatsNewDismissed)
            // This will save the card shown and prevent it from being shown again unless changed
            VersionStore.shared.storeShownCard(card: card)
        }
        
        tableView.beginUpdates()
        UIView.animate(withDuration: 0.35, animations: {
            self.tableView.contentInset = .init(top: -self.whatsNewView.frame.height - 20, left: 0, bottom: 0, right: 0)
            self.whatsNewView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01).translatedBy(x: 0, y: 7000)
            self.whatsNewView.alpha = 0
            for subview in self.whatsNewView.subviews {
                subview.alpha = 0
            }
        }, completion: {(completed) in
            if completed {
                self.tableView.contentInset = .zero
                self.tableView.tableHeaderView = .zero
            }
        })
        tableView.endUpdates()
        
        let payload = WhatsNewCardDismissedPayload(actionDescription: card.title)
        Analytics.shared.log(payload)
    }

    /// Hide card when user is searching for Bus Stops
    func hideCard() {
        guard whatsNewView != nil else { return }
        UIView.animate(withDuration: 0.35, animations: {
            self.tableView.contentInset = .init(top: -self.whatsNewView.frame.height - 20, left: 0, bottom: 0, right: 0)
            self.whatsNewView.alpha = 0
            for subview in self.whatsNewView.subviews {
                subview.alpha = 0
            }
        }) { (_) in
            self.whatsNewView.isHidden = true
        }
    }

    /// Present card after user is done searching
    func showCard() {
        guard whatsNewView != nil else { return }
        UIView.animate(withDuration: 0.35, animations: {
            self.tableView.contentInset = .zero
            self.tableView.contentOffset = .zero
            self.whatsNewView.alpha = 1
            for subview in self.whatsNewView.subviews {
                subview.alpha = 1
            }
        }) { (_) in
            self.whatsNewView.isHidden = false
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
