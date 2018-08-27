//
//  FavoritesTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 11/17/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class FavoritesTableViewController: UITableViewController, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    var fromOnboarding = false
    var timer: Timer?
    var searchBar = UISearchBar()
    var resultsSection: Section! {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = fromOnboarding ? "Add Favorites" : "Add Favorite"
        let systemItem: UIBarButtonSystemItem = fromOnboarding ? .done : .cancel
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            CustomNavigationController.buttonTitleTextAttributes, for: .normal
        )
        
        resultsSection = Section(type: .searchResults, items: [ItemType]())
        
        tableView.register(BusStopCell.self, forCellReuseIdentifier: Constants.Cells.busIdentifier)
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: Constants.Cells.searchResultsIdentifier)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.endEditing(true)
    }

    @objc func dismissVC() {
        if fromOnboarding {
            let rootVC = HomeViewController()
            let desiredViewController = CustomNavigationController(rootViewController: rootVC)

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let snapshot: UIView = appDelegate.window!.snapshotView(afterScreenUpdates: true)!
            desiredViewController.view.addSubview(snapshot)

            appDelegate.window?.rootViewController = desiredViewController
            userDefaults.setValue(true, forKey: Constants.UserDefaults.onboardingShown)

            UIView.animate(withDuration: 0.5, animations: {
                snapshot.layer.opacity = 0
                snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
            }, completion: { _ in
                snapshot.removeFromSuperview()
            })
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsSection.items.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        searchBar.isTranslucent = true
        searchBar.placeholder = Constants.Phrases.favoritesPlaceholder
        searchBar.backgroundImage = UIImage()
        searchBar.alpha = 1.0
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = .tableBackgroundColor
        searchBar.backgroundColor = .white
        searchBar.delegate = self
        return searchBar
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        let item = resultsSection.items[indexPath.row]

        switch item {
        case .busStop(let busStop):
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.busIdentifier, for: indexPath) as! BusStopCell
            cell.textLabel?.text = busStop.name
        case .placeResult(let placeResult):
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.searchResultsIdentifier, for: indexPath) as! SearchResultsCell
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
        
        switch resultsSection.items[indexPath.row] {
        case .busStop(let busStop):
            SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.favorites, location: busStop, limit: 5, bottom: true)
        case .placeResult(let placeResult):
            SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.favorites, location: placeResult, limit: 5, bottom: true)
        default:
            break
        }
        
        dismissVC()
    }
    
    // MARK: Empty Data Set
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -80
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "search-large")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "Search for a destination"
        let attrs = [NSAttributedStringKey.foregroundColor : UIColor.mediumGrayColor]
        return NSAttributedString(string: title, attributes: attrs)
    }
    
    // MARK: Search

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(getPlaces), userInfo: ["searchText": searchText], repeats: false)
    }

    /* Get Search Results */
    @objc func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if searchText.count > 0 {
            Network.getGooglePlacesAutocompleteResults(searchText: searchText).perform(withSuccess: { responseJson in
                self.resultsSection = SearchTableViewManager.shared.parseGoogleJSON(searchText: searchText, json: responseJson)
                self.tableView.contentOffset = .zero
            })
        } else {
            resultsSection = Section(type: .searchResults, items: [ItemType]())
        }
    }

}
