//
//  HomeOptionsCard.swift
//  TCAT
//
//  Created by Omar Rasheed on 3/23/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation
import DZNEmptyDataSet
import GoogleMaps
import NotificationBannerSwift
import SnapKit

protocol HomeOptionsCardDelegate {
    func updateSize()
}

class HomeOptionsCardViewController: UIViewController {
    
    var delegate: HomeOptionsCardDelegate? {
        didSet {
            tableView.optionsCardDelegate = delegate
        }
    }
    
    let reachability = Reachability(hostname: Network.ipAddress)
    var banner: StatusBarNotificationBanner? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var tableView: AutoResizingTableView!
    var searchBar: UISearchBar!
    let infoButton = UIButton(type: .infoLight)
    var searchBarseparator: UIView!
    var timer: Timer?
    var searchResultsSection: Section!

    var isNetworkDown = false
    let searchBarHeight: CGFloat = 54
    let headerHeight: CGFloat = 42
    let tableViewRowHeight: CGFloat = 50
    
    var maxCardHeight: CGFloat {
        /* Returns the height of a card that would contain two favorites and two recent searches.
         This is the height that we will cap all optionCards at, regardless of the phone. */
        
        return tableViewRowHeight * 5 + headerHeight * 2 + searchBarHeight + HeaderView.separatorViewHeight
    }
    var isDynamicSearchBar: Bool {
        /* Checks to see if the bottom of the card at maximum height would cover more than 3/5 of the screen */
        
        return maxCardHeight > (UIScreen.main.bounds.height*3/5 - HomeMapViewController.optionsCardInset.top)
    }
    var recentLocations: [Place] = [] {
        didSet {
            if recentLocations.count > 2 {
                recentLocations = Array(recentLocations.prefix(2))
            }
            if !isNetworkDown {
                if oldValue != recentLocations {
                    sections = createSections()
                }
            }
        }
    }
    var favorites: [Place] = [] {
        didSet {
            if favorites.count > 2 {
                favorites = Array(favorites.prefix(2))
            }
            if !isNetworkDown {
                if oldValue != favorites {
                    sections = createSections()
                }
            }
        }
    }
    var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupInfoButton()
        setupSearchBarseparator()
        setupSearchBar()
        
        setupConstraints()
        
        updatePlaces()
    }

    func setupTableView() {
        tableView = AutoResizingTableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = tableViewRowHeight
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: Constants.Cells.placeIdentifier)
        tableView.register(GeneralTableViewCell.self, forCellReuseIdentifier: Constants.Cells.seeAllStopsIdentifier)
        view.addSubview(tableView)
    }
    
    func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = Constants.General.searchPlaceholder
        searchBar.delegate = self
        searchBar.searchBarStyle = .default
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = .white
        searchBar.barTintColor = .white
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.layer.borderWidth = 1
        view.addSubview(searchBar)
    }
    
    func setupInfoButton() {
        infoButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0)
        infoButton.contentVerticalAlignment = .center
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(openInformationScreen), for: .touchUpInside)
        view.addSubview(infoButton)
    }
    
    func setupSearchBarseparator() {
        searchBarseparator = UIView()
        searchBarseparator.backgroundColor = Colors.backgroundWash
        view.addSubview(searchBarseparator)
    }
    
    func setupConstraints() {
        infoButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(view.snp.top).inset(searchBarHeight/2)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(30)
            make.height.equalTo(38)
        }
        
        searchBar.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview()
            make.trailing.equalTo(infoButton.snp.leading)
            make.height.equalTo(searchBarHeight)
        }
        
        searchBarseparator.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
            make.height.equalTo(1)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBarseparator.snp.bottom)
        }
        
    }
    
    func createSections() -> [Section] {
        var allSections: [Section] = []
        let recentSearchesSection = Section(type: .recentSearches, items: recentLocations)
        let seeAllStops = Place(
            name: Constants.Cells.seeAllStopsIdentifier,
            placeDescription: "dummy_data",
            placeIdentifier: "dummy_data"
        )
        let seeAllStopsSection = Section(type: .seeAllStops, items: [seeAllStops])
        
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
    
    func tableViewContentHeight() -> CGFloat {
        var size: CGFloat = 0
        for section in sections {
            switch section.type {
            case .favorites, .recentSearches: size += headerHeight
            case .seeAllStops: size += HeaderView.separatorViewHeight
            default: break
            }
            size += tableViewRowHeight*CGFloat(section.items.count)
        }
        
        return size
    }
    
    func calculateCardHeight() -> CGFloat {
        // If the screen is too small, decide whether to show full card or just searchBar
        if isDynamicSearchBar {
            if searchBar.isFirstResponder {
                return min(tableViewContentHeight() + CGFloat(searchBarHeight), maxCardHeight)
            } else { return CGFloat(searchBarHeight) }
        }
        return min(tableViewContentHeight() + searchBarHeight, UIScreen.main.bounds.height/2)
    }
    
    func updatePlaces() {
        recentLocations = SearchTableViewManager.shared.retrievePlaces(for: Constants.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrievePlaces(for: Constants.UserDefaults.favorites)
    }
    
    func animateInInfoButton() {
        UIView.animate(withDuration: 0.1) {
            self.infoButton.alpha = 1
            
            self.searchBar.snp.remakeConstraints { (make) in
                make.leading.top.equalToSuperview()
                make.trailing.equalTo(self.infoButton.snp.leading)
                make.height.equalTo(self.searchBarHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func animateOutInfoButton() {
        UIView.animate(withDuration: 0.2) {
            self.infoButton.alpha = 0
            self.searchBar.snp.remakeConstraints { (make) in
                make.leading.top.equalToSuperview()
                make.trailing.equalTo(self.infoButton.snp.trailing)
                make.height.equalTo(self.searchBarHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func presentFavoritesTVC(sender: UIButton? = nil) {
        let favoritesTVC = FavoritesTableViewController()
        let navController = CustomNavigationController(rootViewController: favoritesTVC)
        present(navController, animated: true, completion: nil)
    }
    
    /* Open information screen */
    @objc func openInformationScreen() {
        let informationViewController = InformationViewController()
        let navigationVC = CustomNavigationController(rootViewController: informationViewController)
        present(navigationVC, animated: true)
    }
    
    /* Get Search Results */
    @objc func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if !searchText.isEmpty {
            Network.getSearchResults(searchText: searchText).perform(withSuccess: { response in
                self.searchResultsSection = Section(type: .searchResults, items: response.data)
                self.sections = [self.searchResultsSection]
            })
        } else {
            sections = createSections()
        }
    }
}

// MARK: VC Life Cycle setup
extension HomeOptionsCardViewController {
    override func loadView() {
        let customView = RoundShadowedView()
        customView.addRoundedCornersAndShadow(radius: 10)
        view = customView
    }
    
    @objc func reachabilityChanged(_ notification: Notification) {
        guard let reachability = notification.object as? Reachability else {
            return
        }
        
        // Dismiss current banner or loading indicator, if any
        banner?.dismiss()
        banner = nil
        
        switch reachability.connection {
        case .none:
            banner = StatusBarNotificationBanner(title: Constants.Banner.noInternetConnection, style: .danger)
            banner?.autoDismiss = false
            banner?.show(queuePosition: .front, on: navigationController)
            isNetworkDown = true
            searchBar.isUserInteractionEnabled = false
            sections = []
        case .cellular, .wifi:
            isNetworkDown = false
            sections = createSections()
            searchBar.isUserInteractionEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updatePlaces()
        
        // Add Notification Observers
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(_:)),
                                               name: .reachabilityChanged,
                                               object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("HomeVC viewDidLayoutSubviews: Could not start reachability notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability?.stopNotifier()
        
        // Remove Notification Observers
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        
        // Remove banner and loading indicator
        banner?.dismiss()
        banner = nil
    }
}

// MARK: Search Bar Delegate
extension HomeOptionsCardViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.placeholder = Constants.General.searchPlaceholder
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        searchBar.text = nil
        animateInInfoButton()
        sections = createSections()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(getPlaces), userInfo: ["searchText": searchText], repeats: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.placeholder = nil
        animateOutInfoButton()
        if isDynamicSearchBar {
            tableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.showsCancelButton {
            searchBarCancelButtonClicked(searchBar)
        }
    }
}

// MARK: HeaderView Delegate
extension HomeOptionsCardViewController: HeaderViewDelegate {
    func displayFavoritesTVC() {
        if favorites.count < 2 {
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
    
    func clearRecentSearches() {
        SearchTableViewManager.shared.deleteAllRecents()
        recentLocations = []
        sections = createSections()
    }
}

// MARK: TableView DataSource
extension HomeOptionsCardViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
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
}

// MARK: TableView Delegate
extension HomeOptionsCardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section].type {
        case .favorites, .recentSearches: return headerHeight
        case .seeAllStops: return HeaderView.separatorViewHeight
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderView()
        
        switch sections[section].type {
        case .recentSearches:
            header.setupView(labelText: Constants.TableHeaders.recentSearches, buttonType: .clear, separatorVisible: true)
            header.headerViewDelegate = self
        case .favorites:
            header.setupView(labelText: Constants.TableHeaders.favoriteDestinations, buttonType: .add)
            header.headerViewDelegate = self
        case .seeAllStops:
            header.setupView(separatorVisible: true)
        case .searchResults:
            return nil
        default: break
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let section = sections[indexPath.section]
        switch section.type {
        case .favorites:
            if !section.items.isEmpty, section.items[0].name != Constants.General.firstFavorite {
                return .delete
            } else {
                return .none
            }
        case .recentSearches: return .delete
        default: return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch sections[indexPath.section].type {
            case .favorites:
                let place = sections[indexPath.section].items[indexPath.row]
                favorites = SearchTableViewManager.shared.deleteFavorite(favorite: place, allFavorites: favorites)
                sections = createSections()
            case .recentSearches:
                let place = sections[indexPath.section].items[indexPath.row]
                recentLocations = SearchTableViewManager.shared.deleteRecent(recent: place, allRecents: recentLocations)
                sections = createSections()
            default: break
            }
            
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

// Always updates size of view when reloading cells
class AutoResizingTableView: UITableView {
    var optionsCardDelegate: HomeOptionsCardDelegate?
    
    override func reloadData() {
        super.reloadData()
        layoutIfNeeded()
        optionsCardDelegate?.updateSize()
    }
}

// Necessary to have shadows AND rounded corners
private class RoundShadowedView: UIView {
    
    var containerView: UIView!
    
    func addRoundedCornersAndShadow(radius: CGFloat) {
        backgroundColor = .clear
        
        layer.shadowColor = Colors.secondaryText.cgColor
        layer.shadowOffset = CGSize(width: 0, height: radius/4)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = radius/4
        
        containerView = UIView()
        containerView.backgroundColor = .white
        
        containerView.layer.cornerRadius = radius
        containerView.layer.masksToBounds = true
        
        addSubview(containerView)
        
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func addSubview(_ view: UIView) {
        if view.isEqual(containerView) {
            super.addSubview(view)
        } else {
            containerView.addSubview(view)
        }
    }
}
