//
//  FavoritesTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 11/17/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController, UISearchBarDelegate {

    var timer: Timer?
    var allStops: [BusStop]!
    var resultsSection: Section! {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Favorite"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
        let titleAttributes: [NSAttributedStringKey: Any] = [.font : UIFont(name :".SFUIText", size: 18)!, .foregroundColor : UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        allStops = SearchTableViewManager.shared.getAllStops()
        tableView.register(BusStopCell.self, forCellReuseIdentifier: Key.Cells.busIdentifier)
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: Key.Cells.searchResultsIdentifier)

        resultsSection = Section(type: .searchResults, items: [ItemType]())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsSection.items.isEmpty ? allStops.count : resultsSection.items.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchBar = UISearchBar()
        searchBar.isTranslucent = true
        searchBar.backgroundImage = UIImage()
        searchBar.alpha = 1.0
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = .tableBackgroundColor
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedStringKey.foregroundColor: UIColor.searchBarPlaceholderTextColor])
       searchBar.backgroundColor = .white
        searchBar.delegate = self
        return searchBar
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if resultsSection.items.isEmpty {
         let cell = tableView.dequeueReusableCell(withIdentifier: Key.Cells.busIdentifier, for: indexPath) as! BusStopCell
        cell.textLabel?.text = allStops[indexPath.row].name
        return cell
        }

        let item = resultsSection.items[indexPath.row]

        switch item {
        case .busStop(let busStop):
            cell = tableView.dequeueReusableCell(withIdentifier: Key.Cells.busIdentifier, for: indexPath) as! BusStopCell
            cell.textLabel?.text = busStop.name
        case .placeResult(let placeResult):
            cell = tableView.dequeueReusableCell(withIdentifier: Key.Cells.searchResultsIdentifier, for: indexPath) as! SearchResultsCell
            cell.textLabel?.text = placeResult.name
            cell.detailTextLabel?.text = placeResult.detail
        default:
            return UITableViewCell()
        }
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.layoutSubviews()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if resultsSection.items.isEmpty { //we selected from allStops array
            let busStopSelected = allStops[indexPath.row]
            SearchTableViewManager.shared.insertPlace(for: Key.UserDefaults.favorites, location: busStopSelected, limit: 5, bottom: true)
        } else {
            switch resultsSection.items[indexPath.row] {
            case .busStop(let busStop):
                SearchTableViewManager.shared.insertPlace(for: Key.UserDefaults.favorites, location: busStop, limit: 5, bottom: true)
            case .placeResult(let placeResult):
                SearchTableViewManager.shared.insertPlace(for: Key.UserDefaults.favorites, location: placeResult, limit: 5, bottom: true)
            default:
                break
            }
        }
        dismissVC()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(getPlaces), userInfo: ["searchText": searchText], repeats: false)
    }

    /* Get Search Results */
    @objc func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if searchText.count > 0 {
            Network.getGooglePlaces(searchText: searchText).perform(withSuccess: { responseJson in
                self.resultsSection = SearchTableViewManager.shared.parseGoogleJSON(searchText: searchText, json: responseJson)
                self.tableView.contentOffset = .zero
            })
        } else {
            resultsSection = Section(type: .searchResults, items: [ItemType]())
        }
    }

}
