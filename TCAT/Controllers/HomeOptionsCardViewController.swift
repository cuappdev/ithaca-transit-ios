//
//  HomeOptionsCard.swift
//  TCAT
//
//  Created by Omar Rasheed on 3/23/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import CoreLocation
import DZNEmptyDataSet
import FutureNova
import GoogleMaps
import SnapKit
import UIKit

protocol HomeOptionsCardDelegate {
    func updateSize()
    func getCurrentLocation() -> CLLocation?
}

class HomeOptionsCardViewController: UIViewController {

    var searchBar: UISearchBar!

    var delegate: HomeOptionsCardDelegate?

    private let infoButton = UIButton(type: .infoLight)
    private var searchBarSeparator: UIView!
    private var tableView: UITableView!

    private var currentLocation: CLLocation? { return delegate?.getCurrentLocation() }
    private let networking: Networking = URLSession.shared.request
    private var searchResultsSection: Section!
    private var timer: Timer?

    private let headerHeight: CGFloat = 42
    private let infoButtonAnimationDuration = 0.1
    private var isLoading: Bool { return loadingIndicator != nil }
    private var isNetworkDown = false
    private var loadingIndicator: LoadingIndicator?
    private var keyboardHeight: CGFloat = 0
    private let maxFavoritesCount = 2
    private let maxHeaderCount: CGFloat = 2
    private let maxRecentsCount = 2
    private let maxRowCount: CGFloat = 5
    private let maxScreenCoverage: CGFloat = 3/5
    private let maxSeparatorCount: CGFloat = 1
    private let searchBarHeight: CGFloat = 54
    private let searchBarSeparatorHeight: CGFloat = 1
    private let searchBarTopOffset: CGFloat = 3 // Add top offset to search bar so that the search bar text is vertically centered.
    private let tableViewRowHeight: CGFloat = 50

    /** Height of the card when collapsed. This includes just searchbar height and any extra padding/spacing */
    private var collapsedHeight: CGFloat {
        return searchBarHeight + searchBarSeparatorHeight + searchBarTopOffset
    }

    /** Returns the height of a card that would contain two favorites and two recent searches. */
    private var maxCardHeight: CGFloat {
        let totalRowHeight = tableViewRowHeight * maxRowCount
        let totalHeaderHeight = headerHeight * maxHeaderCount
        let totalSeparatorHeight = HeaderView.separatorViewHeight * maxSeparatorCount
        return totalRowHeight + totalHeaderHeight + totalSeparatorHeight + collapsedHeight
    }

    /** Returns the maximum height of the options card given the size of the phone. If the usual
     max height would make the card get covered by the keyboard, then we adjust it to be smaller.
     Otherwise, we keep it at the maximum height. */
    private var adjustedMaxCardHeight: CGFloat {
        let openScreenSpace = UIScreen.main.bounds.height - HomeMapViewController.optionsCardInset.top - keyboardHeight - 20
        return min(maxCardHeight, openScreenSpace)
    }

    private var recentLocations: [Place] = [] {
        didSet {
            if recentLocations.count > maxRecentsCount {
                recentLocations = Array(recentLocations.prefix(maxRecentsCount))
            }
            if !isNetworkDown {
                createDefaultSections()
            }
        }
    }
    private var favorites: [Place] = [] {
        didSet {
            if favorites.count > maxFavoritesCount {
                favorites = Array(favorites.prefix(maxFavoritesCount))
            }
            if !isNetworkDown {
                createDefaultSections()
            }
        }
    }
    private var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
            DispatchQueue.main.async {
                self.delegate?.updateSize()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupInfoButton()
        setupSearchBarSeparator()
        setupSearchBar()
        setupConstraints()
        updatePlaces()
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = tableViewRowHeight
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: Constants.Cells.placeIdentifier)
        tableView.register(GeneralTableViewCell.self, forCellReuseIdentifier: Constants.Cells.generalCellIdentifier)
        view.addSubview(tableView)
    }

    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = Constants.General.searchPlaceholder
        searchBar.delegate = self
        searchBar.searchBarStyle = .default
        searchBar.returnKeyType = .search
        searchBar.barTintColor = .white
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.layer.borderWidth = 1

        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField,
            let searchView = textFieldInsideSearchBar.leftView as? UIImageView {
            textFieldInsideSearchBar.backgroundColor = Colors.white
            searchView.image = #imageLiteral(resourceName: "search-large")
        }

        // Add horizontal offset so that placeholder text is aligned with bus stop names and all stops
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)
        view.addSubview(searchBar)
    }

    private func setupInfoButton() {
        infoButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0)
        infoButton.contentVerticalAlignment = .center
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(openInformationScreen), for: .touchUpInside)
        view.addSubview(infoButton)
    }

    private func setupSearchBarSeparator() {
        searchBarSeparator = UIView()
        searchBarSeparator.backgroundColor = Colors.backgroundWash
        view.addSubview(searchBarSeparator)
    }

    private func setupConstraints() {
        let infoButtonSize = CGSize.init(width: 30, height: 38)
        let infoButtonTrailinginset = 16

        infoButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(searchBar).offset(-searchBarTopOffset / 2)
            make.trailing.equalToSuperview().inset(infoButtonTrailinginset)
            make.size.equalTo(infoButtonSize)
        }

        searchBar.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().inset(searchBarTopOffset)
            make.trailing.equalTo(infoButton.snp.leading)
            make.height.equalTo(searchBarHeight)
        }

        searchBarSeparator.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
            make.height.equalTo(searchBarSeparatorHeight)
        }

        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBarSeparator.snp.bottom)
        }
    }

    private func createDefaultSections() {
        var allSections: [Section] = []
        let recentSearchesSection = Section(type: .recentSearches, items: recentLocations)
        let seeAllStops = Place(name: Constants.Cells.generalCellIdentifier)
        let seeAllStopsSection = Section(type: .seeAllStops, items: [seeAllStops])
        var favoritesSection = Section(type: .favorites, items: favorites)
        if favoritesSection.items.isEmpty {
            let addFavorites = Place(
                name: Constants.General.firstFavorite,
                placeDescription: Constants.General.tapHere)
            addFavorites.type = .busStop // Special exception to make pin blue for favorite!
            favoritesSection = Section(type: .favorites, items: [addFavorites])
        }
        allSections.append(favoritesSection)
        allSections.append(recentSearchesSection)
        allSections.append(seeAllStopsSection)
        sections = allSections.filter { !$0.items.isEmpty || $0.type == .seeAllStops }
    }

    private func tableViewContentHeight() -> CGFloat {
        return sections.reduce(0) { (result, section) -> CGFloat in
            var sectionHeaderHeight: CGFloat = 0
            switch section.type {
            case .favorites, .recentSearches: sectionHeaderHeight = headerHeight
            case .seeAllStops: sectionHeaderHeight = HeaderView.separatorViewHeight
            default: break
            }
            return sectionHeaderHeight + tableViewRowHeight * CGFloat(section.items.count) + result
        }
    }

    /// Decide whether to show full card or just searchBar
    func calculateCardHeight() -> CGFloat {
        if searchBar.isFirstResponder {
            let contentHeight = tableViewContentHeight() + collapsedHeight
            return min(contentHeight, adjustedMaxCardHeight)
        } else { return collapsedHeight }
    }

    private func updatePlaces() {
        recentLocations = SearchTableViewManager.shared.retrievePlaces(for: Constants.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrievePlaces(for: Constants.UserDefaults.favorites)
    }

    private func animateInInfoButton() {
        UIView.animate(withDuration: infoButtonAnimationDuration) {
            self.infoButton.alpha = 1

            self.searchBar.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview()
                make.top.equalToSuperview().inset(self.searchBarTopOffset)
                make.trailing.equalTo(self.infoButton.snp.leading)
                make.height.equalTo(self.searchBarHeight)
            }
            self.view.layoutIfNeeded()
        }
    }

    private func animateOutInfoButton() {
        UIView.animate(withDuration: infoButtonAnimationDuration) {
            self.infoButton.alpha = 0
            self.searchBar.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview()
                make.top.equalToSuperview().inset(self.searchBarTopOffset)
                make.trailing.equalTo(self.infoButton.snp.trailing)
                make.height.equalTo(self.searchBarHeight)
            }
            self.view.layoutIfNeeded()
        }
    }

    private func getSearchResults(searchText: String) -> Future<Response<[Place]>> {
        return networking(Endpoint.getSearchResults(searchText: searchText)).decode()
    }

    @objc private func presentFavoritesTVC(sender: UIButton? = nil) {
        let favoritesTVC = FavoritesTableViewController()
        let navController = CustomNavigationController(rootViewController: favoritesTVC)
        present(navController, animated: true, completion: nil)
    }

    /* Open information screen */
    @objc private func openInformationScreen() {
        let informationViewController = InformationViewController()
        let navigationVC = CustomNavigationController(rootViewController: informationViewController)
        present(navigationVC, animated: true)
    }

    /* Get Search Results */
    @objc private func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if !searchText.isEmpty {
            getSearchResults(searchText: searchText).observe { [weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .value(let response):
                        self.searchResultsSection = Section(type: .searchResults, items: response.data)
                        self.tableView.contentOffset = .zero
                        self.sections = [self.searchResultsSection]
                    default: break
                    }
                }
            }
        } else {
            createDefaultSections()
        }
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
    }
}

// MARK: VC Life Cycle setup
extension HomeOptionsCardViewController {
    override func loadView() {
        let customView = RoundShadowedView()
        customView.addRoundedCornersAndShadow()
        view = customView
    }

    override func viewWillAppear(_ animated: Bool) {
        // Update searchbar attributes
        if let textFieldInsideSearchBar = searchBar.value(forKey: Constants.SearchBar.searchField) as? UITextField,
            let searchView = textFieldInsideSearchBar.leftView as? UIImageView {
            textFieldInsideSearchBar.backgroundColor = Colors.white
            searchView.image = #imageLiteral(resourceName: "search-large")
        }
        searchBar.placeholder = Constants.General.searchPlaceholder
        searchBar.text = nil

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        updatePlaces()
        createDefaultSections()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        removeLoadingIndicator()
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
        createDefaultSections()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.returnKeyType = searchText.isEmpty ? .default : .search
        searchBar.setShowsCancelButton(true, animated: true)
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(getPlaces), userInfo: ["searchText": searchText], repeats: false)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        if let cancelButton = searchBar.value(forKey: Constants.SearchBar.cancelButton) as? UIButton {
            cancelButton.setTitleColor(Colors.tcatBlue, for: .normal)
        }

        searchBar.placeholder = nil
        animateOutInfoButton()
        if view.frame.height == collapsedHeight {
            if let searchText = searchBar.text,
                searchText.isEmpty {
                createDefaultSections()
            } else {
                tableView.reloadData()
                DispatchQueue.main.async {
                    self.delegate?.updateSize()
                }
            }
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
        createDefaultSections()
    }
}

// MARK: MapView Delegate
extension HomeOptionsCardViewController: HomeMapViewDelegate {
    func reachabilityChanged(connection: Reachability.Connection) {
        switch connection {
        case .none:
            isNetworkDown = true
//            searchBar.isUserInteractionEnabled = false
            sections = []
        case .cellular, .wifi:
            isNetworkDown = false
            createDefaultSections()
            searchBar.isUserInteractionEnabled = true
        }
    }

    func mapViewWillMove() {
        if let searchBarText = searchBar.text,
            searchBarText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.searchBarCancelButtonClicked(self.searchBar)
        } else {
            searchBar.resignFirstResponder()
            DispatchQueue.main.async {
                self.delegate?.updateSize()
            }
        }
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
        if sections[indexPath.section].type == .seeAllStops {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.generalCellIdentifier) as! GeneralTableViewCell
            cell.configure(for: .seeAllStops)
            return cell
        }
            // Favorites (including Add First Favorite!), Recent Searches
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.placeIdentifier) as! PlaceTableViewCell
            cell.configure(for: sections[indexPath.section].items[indexPath.row])
            return cell
        }
    }
}

// MARK: TableView Delegate
extension HomeOptionsCardViewController: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let searchBarText = searchBar.text,
            searchBarText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searchBar.placeholder = Constants.General.searchPlaceholder
            searchBar.endEditing(true)
            searchBar.text = nil
        }
        searchBar.setShowsCancelButton(false, animated: true)
        animateInInfoButton()
    }

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
                createDefaultSections()
            case .recentSearches:
                let place = sections[indexPath.section].items[indexPath.row]
                recentLocations = SearchTableViewManager.shared.deleteRecent(recent: place, allRecents: recentLocations)
                createDefaultSections()
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
        } else {
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

// MARK: DZN Empty Data Set Source
extension HomeOptionsCardViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
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
