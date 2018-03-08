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
import SwiftRegister

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, AddFavoritesDelegate {
    let userDefaults = UserDefaults.standard
    let cornellDestinations = [(name: "North Campus", stops: "RPCC, Balch Hall, Appel, Helen Newman, Jessup Field"),
                               (name: "West Campus", stops: "Baker Flagpole, Baker Flagpole (Slopeside)"),
                               (name: "Central Campus", stops: "Statler Hall, Uris Hall, Goldwin Smith Hall"),
                               (name: "Collegetown", stops: "Collegetown Crossing, Schwartz Center"),
                               (name: "Ithaca Commons", stops: "Albany @ Salvation Army, State Street, Lot 32")]

    var timer: Timer?
    var isNetworkDown = false
    var searchResultsSection: Section!
    var sectionIndexes: [String: Int]! = [:]
    var tableView : UITableView!
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
    var isBannerShown = false
    
    var banner: StatusBarNotificationBanner {
        let banner = StatusBarNotificationBanner(title: "No internet connection. Retrying...", style: .danger)
        banner.autoDismiss = false
        return banner
    }
    
    func tctSectionHeaderFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 14)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Add Notification Observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        recentLocations = SearchTableViewManager.shared.retrieveRecentPlaces(for: Key.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrieveRecentPlaces(for: Key.UserDefaults.favorites)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        view.backgroundColor = .tableBackgroundColor
        
        infoButton.addTarget(self, action: #selector(openInformationScreen), for: .touchUpInside)
        infoButton.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(38)
        }
        infoButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 0)
        let submitBugBarButton = UIBarButtonItem(customView: infoButton)
        navigationItem.setRightBarButton(submitBugBarButton, animated: false)

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
        tableView.register(BusStopCell.self, forCellReuseIdentifier: Key.Cells.busIdentifier)
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: Key.Cells.searchResultsIdentifier)
        tableView.register(CornellDestinationCell.self, forCellReuseIdentifier: Key.Cells.cornellDestinationsIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Key.Cells.seeAllStopsIdentifier)
        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo((navigationController?.navigationBar.bounds.maxY)!)
        }

        searchBar = UISearchBar()
        searchBar.placeholder = "Search (e.g Balch Hall, 312 College Ave)"
        searchBar.delegate = self
        searchBar.searchBarStyle = .default
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = .tableBackgroundColor
        navigationItem.titleView = searchBar
    }

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("HomeVC viewDidLayoutSubviews: Could not start reachability notifier")
        }
        if searchBar.showsCancelButton {
            searchBar.becomeFirstResponder()
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
            case .none:
                banner.show(queuePosition: .front, on: self)
                isBannerShown = true
                UIApplication.shared.statusBarStyle = .lightContent
                self.isNetworkDown = true
                self.sectionIndexes = [:]
                self.searchBar.isUserInteractionEnabled = false
                self.sections = []
            case .cellular, .wifi:
                if isBannerShown {
                    banner.dismiss()
                    isBannerShown = false
                    UIApplication.shared.statusBarStyle = .default
                }
                sections = createSections()
                self.searchBar.isUserInteractionEnabled = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }

    override func viewWillAppear(_ animated: Bool) {
        recentLocations = SearchTableViewManager.shared.retrieveRecentPlaces(for: Key.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrieveRecentPlaces(for: Key.UserDefaults.favorites)
        sections = createSections()
    }

    func createSections() -> [Section] {
        var allSections: [Section] = []
        let recentSearchesSection = Section(type: .recentSearches, items: recentLocations)
        let seeAllStopsSection = Section(type: .seeAllStops, items: [.seeAllStops])
        var favoritesSection = Section(type: .favorites, items: favorites)

        if favoritesSection.items.isEmpty {
            let addFavorites = BusStop(name: Key.Favorites.first, lat: 0.0, long: 0.0)
            favoritesSection = Section(type: .favorites, items: [.busStop(addFavorites)])
        }
        allSections.append(favoritesSection)
        allSections.append(recentSearchesSection)
        allSections.append(seeAllStopsSection)
        return allSections.filter({$0.items.count > 0})
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

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

    @objc func presentFavoritesTVC(sender: UIButton? = nil) {
        let favoritesTVC = FavoritesTableViewController()
        let navController = CustomNavigationController(rootViewController: favoritesTVC)
        present(navController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && !favorites.isEmpty
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var itemType : ItemType?
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
                cell = tableView.dequeueReusableCell(withIdentifier: Key.Cells.busIdentifier) as! BusStopCell
                cell.textLabel?.text = busStop.name
            case .placeResult(let placeResult):
                cell = tableView.dequeueReusableCell(withIdentifier: Key.Cells.searchResultsIdentifier) as! SearchResultsCell
                cell.textLabel?.text = placeResult.name
                cell.detailTextLabel?.text = placeResult.detail
            case .cornellDestination:
                cell = tableView.dequeueReusableCell(withIdentifier: Key.Cells.cornellDestinationsIdentifier) as! CornellDestinationCell
                cell.textLabel?.text = cornellDestinations[indexPath.row].name
                cell.detailTextLabel?.text = cornellDestinations[indexPath.row].stops
            case .seeAllStops:
                cell = tableView.dequeueReusableCell(withIdentifier: Key.Cells.seeAllStopsIdentifier)
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
            if busStop.name == Key.Favorites.first { //we want to go to favoritesvc
                presentOptionsVC = false
                presentFavoritesTVC()
            } else {
            SearchTableViewManager.shared.insertPlace(for: Key.UserDefaults.recentSearch, location: busStop, limit: 8)
            optionsVC.searchTo = busStop
            }
        case .placeResult(let placeResult):
            SearchTableViewManager.shared.insertPlace(for: Key.UserDefaults.recentSearch, location: placeResult, limit: 8)
            optionsVC.searchTo = placeResult
        }

        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.endEditing(true)
        let vcToPush = didSelectAllStops ? allStopsTVC : optionsVC
        if presentOptionsVC {
            navigationController?.pushViewController(vcToPush, animated: true)
        }
        
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -80.0
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return isNetworkDown ? #imageLiteral(resourceName: "noInternet") : #imageLiteral(resourceName: "emptyPin")
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = isNetworkDown ? "No Network Connection" : "Location Not Found"
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.mediumGrayColor]
        return NSAttributedString(string: title, attributes: attrs)
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let buttonTitle = isNetworkDown ? "Try Again" : ""
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.noInternetTextColor]
        return NSAttributedString(string: buttonTitle, attributes: attrs)
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        //getBusStops()
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
    
    /* SearchBar Delegates */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.placeholder = nil
        navigationItem.rightBarButtonItem = nil
        let _ = RegisterSession.shared?.logEvent(event: SearchBarTappedEventPayload(location: .home).toEvent())
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search (e.g. Balch Hall, 312 College Ave)"
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

    /* Get Search Results */
    @objc func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if searchText.count > 0 {
            Network.getGooglePlaces(searchText: searchText).perform(withSuccess: { responseJson in
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
        self.present(navigationVC, animated: true, completion: nil)
    }
}


