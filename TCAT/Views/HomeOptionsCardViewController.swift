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
import SnapKit

protocol HomeOptionsCardDelegate {
    func updateSize()
}

class HomeOptionsCardViewController: UIViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UISearchBarDelegate {
    
    var delegate: HomeOptionsCardDelegate?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var tableView: UITableView!
    var searchBar: UISearchBar!
    var recentLocations: [Place] = [] {
        didSet {
            if recentLocations.count > 2 {
                recentLocations = Array(recentLocations.prefix(2))
            }
        }
    }
    var favorites: [Place] = [] {
        didSet {
            if favorites.count > 2 {
                favorites = Array(favorites.prefix(2))
            }
        }
    }
    var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
            if sections.isEmpty {
                tableView.tableHeaderView = .zero
            }
        }
    }
    let searchBarHeight = 54
    var searchBarSeperator: UIView!
    
    override func loadView() {
        let customView = RoundShadowedView()
        customView.addRoundedCornersAndShadow(radius: 10)
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchBar()
        setupSearchBarSeperator()
        
        setupConstraints()
    }

    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
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
    
    func setupSearchBarSeperator() {
        searchBarSeperator = UIView()
        searchBarSeperator.backgroundColor = Colors.backgroundWash
        view.addSubview(searchBarSeperator)
    }
    
    func setupConstraints() {
        searchBar.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(searchBarHeight)
        }
        
        searchBarSeperator.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
            make.height.equalTo(1)
        }
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBarSeperator.snp.bottom)
        }
        
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
    
    func calculateCardHeight() -> CGFloat {
        return tableView.contentSize.height + CGFloat(searchBarHeight)
    }
    
    @objc func presentFavoritesTVC(sender: UIButton? = nil) {
        let favoritesTVC = FavoritesTableViewController()
        let navController = CustomNavigationController(rootViewController: favoritesTVC)
        present(navController, animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            print(change)
            delegate?.updateSize()
        }
    }
}

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

extension HomeOptionsCardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var containerView: UIView?
        let header = HeaderView()
        
        switch sections[section].type {
        case .recentSearches:
            header.setupView(labelText: Constants.TableHeaders.recentSearches, displayAddButton: false)
            containerView = UIView()
            
            let seperatorView = UIView()
            seperatorView.backgroundColor = Colors.backgroundWash
            containerView?.addSubview(seperatorView)
            containerView?.addSubview(header)
            
            seperatorView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(1)
                make.top.equalToSuperview()
            }
            
            header.snp.makeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(seperatorView.snp.bottom)
            }
        case .favorites:
            header.setupView(labelText: Constants.TableHeaders.favoriteDestinations, displayAddButton: true)
            header.addFavoritesDelegate = self
        case .seeAllStops:
            containerView = UIView()
            let seperatorView = UIView()
            seperatorView.backgroundColor = Colors.backgroundWash
            containerView?.addSubview(seperatorView)
            containerView?.backgroundColor = .white
            
            seperatorView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(1)
                make.top.equalToSuperview()
            }
        case .searchResults:
            return nil
        default: break
        }
        
        if let headerView = containerView {
            return headerView
        } else {
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section].type {
        case .favorites, .recentSearches: return 42
        case .seeAllStops: return 1
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

extension HomeOptionsCardViewController: HomeMapViewDelegate {
    func searchCancelButtonClicked() {
        searchBar.placeholder = Constants.General.searchPlaceholder
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        searchBar.text = nil
    }
    
    func updatePlaces() {
        recentLocations = SearchTableViewManager.shared.retrievePlaces(for: Constants.UserDefaults.recentSearch)
        favorites = SearchTableViewManager.shared.retrievePlaces(for: Constants.UserDefaults.favorites)
    }
    
    func networkDown() {
       searchBar.isUserInteractionEnabled = false
       sections = []
    }
    
    func networkUp() {
        sections = createSections()
        searchBar.isUserInteractionEnabled = true
    }
}

extension HomeOptionsCardViewController: AddFavoritesDelegate {
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
}

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
