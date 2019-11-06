//
//  HomeOptionsCardViewController+Extensions.swift
//  TCAT
//
//  Created by Omar Rasheed on 8/29/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

// MARK: - VC Life Cycle setup
extension HomeOptionsCardViewController {

    override func loadView() {
        view = RoundShadowedView(cornerRadius: 10)
    }

    override func viewWillAppear(_ animated: Bool) {
        // Update searchbar attributes
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - SearchBar Delegate
extension HomeOptionsCardViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.placeholder = Constants.General.searchPlaceholder
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        searchBar.text = nil
        animateInInfoButton()
        updateSections()
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
                updateSections()
            } else {
                tableView.reloadData()
                DispatchQueue.main.async {
                    self.delegate?.updateSize()
                }
            }
        }
    }
}

// MARK: - HeaderView Delegate
extension HomeOptionsCardViewController: HeaderViewDelegate {

    func presentFavoritePicker() {
        if favorites.count < 2 {
            let favoritesTVC = FavoritesTableViewController()
            favoritesTVC.didAddFavorite = {
                self.updatePlaces() 
            }
            let navController = CustomNavigationController(rootViewController: favoritesTVC)
            present(navController, animated: true, completion: nil)
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
        Global.shared.deleteAllRecents()
        recentLocations = []
        updateSections()
    }

}

// MARK: - MapView Delegate
extension HomeOptionsCardViewController: HomeMapViewDelegate {

    func reachabilityChanged(connection: Reachability.Connection) {
        switch connection {
        case .none:
            isNetworkDown = true
            searchBar.isUserInteractionEnabled = false
            sections = []
        case .cellular, .wifi:
            isNetworkDown = false
            updateSections()
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

// MARK: - TableView DataSource
extension HomeOptionsCardViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .seeAllStops: return 1
        case .recentSearches: return recentLocations.count
        case .favorites: return favorites.isEmpty ? 1 : favorites.count
        case .searchResults: return sections[section].getItems().count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        switch section {
        case .seeAllStops:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.generalCellIdentifier, for: indexPath) as? GeneralTableViewCell else { return UITableViewCell() }
            cell.configure(for: .seeAllStops)
            return cell
        case .favorites(items: let favoritePlaces):
            if favoritePlaces.count > 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.placeIdentifier) as? PlaceTableViewCell
                    else { return UITableViewCell() }
                cell.configure(for: favoritePlaces[indexPath.row])
                return cell
            } else { // If there are no favorites, show an AddFavorite cell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.addFavoriteIdentifier) as? AddFavoriteTableViewCell
                    else { return UITableViewCell() }
                return cell
            }
        default: // Recent searches, etc.
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.placeIdentifier) as? PlaceTableViewCell
                else { return UITableViewCell() }
            cell.configure(for: sections[indexPath.section].getItems()[indexPath.row])
            return cell
        }
    }

}

// MARK: - TableView Delegate
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
        switch sections[section] {
        case .favorites, .recentSearches:
            return headerHeight
        case .seeAllStops:
            return HeaderView.separatorViewHeight
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch sections[section] {
        case .recentSearches:
            return HeaderView(
                labelText: Constants.TableHeaders.recentSearches,
                buttonType: .clear,
                separatorVisible: true,
                delegate: self
            )
        case .favorites:
            return HeaderView(
                labelText: Constants.TableHeaders.favoriteDestinations,
                buttonType: .add,
                delegate: self
            )
        case .seeAllStops:
            return HeaderView(separatorVisible: true)
        case .searchResults:
            return nil
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let section = sections[indexPath.section]
        switch section {
        case .favorites:
            return section.isEmpty ? .none : .delete
        case .recentSearches:
            return .delete
        default:
            return .none
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch sections[indexPath.section] {
            case .favorites:
                let place = sections[indexPath.section].getItems()[indexPath.row]
                favorites = Global.shared.deleteFavorite(favorite: place, allFavorites: favorites)
                updateSections()
            case .recentSearches:
                let place = sections[indexPath.section].getItems()[indexPath.row]
                recentLocations = Global.shared.deleteRecent(recent: place, allRecents: recentLocations)
                updateSections()
            default: break
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .seeAllStops:
            let stopPickerVC = StopPickerViewController()
            stopPickerVC.onSelection = { place in
                let optionsVC = RouteOptionsViewController(searchTo: place)
                self.navigationController?.pushViewController(optionsVC, animated: true)
            }
            navigationController?.pushViewController(stopPickerVC, animated: true)
        case .favorites(items: let places):
            if places.count == 0 {
                presentFavoritePicker()
            } else {
                navigationController?.pushViewController(RouteOptionsViewController(searchTo: places[indexPath.row]), animated: true)
            }
        default:
            if let searchText = searchBar.text {
                let payload = SearchResultSelectedPayload(
                    searchText: searchText,
                    selectedIndex: indexPath.row,
                    totalResults: sections[indexPath.section].getItems().count
                )
                Analytics.shared.log(payload)
            }
            
            let place = sections[indexPath.section].getItems()[indexPath.row]
            Global.shared.insertPlace(for: Constants.UserDefaults.recentSearch, place: place)
            
            let routeOptionsVC = RouteOptionsViewController(searchTo: place)
            routeOptionsVC.didReceiveCurrentLocation(currentLocation)
            navigationController?.pushViewController(routeOptionsVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.endEditing(true)
    }
}
