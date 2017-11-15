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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
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
    var recentLocations: [ItemType] = []
    var isKeyboardVisible = false
    var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    let reachability = Reachability(hostname: Network.source)
    var isBannerShown = false
    var banner: StatusBarNotificationBanner?
    
    func tctSectionHeaderFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 14)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add Notification Observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        recentLocations = retrieveRecentLocations()
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        view.backgroundColor = .tableBackgroundColor
        definesPresentationContext = true
        let searchBarFrame = CGRect(x: 0, y: 0, width: view.bounds.width * 0.934, height: 80)
        searchBar = UISearchBar(frame: searchBarFrame)
        searchBar.placeholder = "Search (e.g Balch Hall, 312 College Ave)"
        searchBar.delegate = self
        searchBar.isTranslucent = false
        searchBar.searchBarStyle = .default
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = .tableBackgroundColor
        
        navigationItem.titleView = searchBar
        
        let tableViewFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - (navigationController?.navigationBar.bounds.height)!)
        tableView = UITableView(frame: tableViewFrame, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        tableView.separatorColor = .lineColor
        tableView.keyboardDismissMode = .onDrag
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "busStop")
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: "searchResults")
        tableView.register(CornellDestinationCell.self, forCellReuseIdentifier: "cornellDestinations")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "seeAllStops")
        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("HomeVC viewDdiLayoutSubviews: Could not start reachability notifier")
        }

        recentLocations = retrieveRecentLocations()
        if searchBar.showsCancelButton {
            searchBar.becomeFirstResponder()
        }
        //sections = createSections()
    }

    func reachabilityChanged(note: Notification) {
        if banner == nil {
            banner = StatusBarNotificationBanner(title: "No Internet Connection", style: .danger)
            banner?.autoDismiss = false
        }
        let reachability = note.object as! Reachability
        switch reachability.connection {
            case .none:
                isBannerShown = true
                banner?.show(queuePosition: .front, on: self)
                self.isNetworkDown = true
                self.sectionIndexes = [:]
                self.searchBar.isUserInteractionEnabled = false
                self.sections = []
            case .cellular, .wifi:
                if isBannerShown {
                    banner?.dismiss()
                    isBannerShown = false
                }
                sections = createSections()
                self.searchBar.isUserInteractionEnabled = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }

    func createSections() -> [Section] {
        var allSections: [Section] = []
        let recentSearchesSection = Section(type: .recentSearches, items: recentLocations)
//        let cornellDestinationSection = Section(type: .cornellDestination, items: [.cornellDestination])
//        allSections.append(cornellDestinationSection)
        let seeAllStopsSection = Section(type: .seeAllStops, items: [.seeAllStops])
        allSections.append(recentSearchesSection)
        allSections.append(seeAllStopsSection)
        return allSections.filter({$0.items.count > 0})
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .secondaryTextColor
        header.textLabel?.font = tctSectionHeaderFont()
        switch sections[section].type {
        case .cornellDestination: header.textLabel?.text = "Get There Now"
        case .recentSearches: header.textLabel?.text = "Recent Searches"
        case .seeAllStops, .searchResults: header.textLabel?.text = nil
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section].type {
        case .cornellDestination: return "Get There Now"
        case .recentSearches: return "Recent Searches"
        case .seeAllStops, .searchResults: return nil
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var itemType : ItemType?
        var cell: UITableViewCell!
        
        switch sections[indexPath.section].type {
        case .cornellDestination:
            itemType = .cornellDestination
        case .recentSearches, .seeAllStops, .searchResults:
            itemType = sections[indexPath.section].items[indexPath.row]
        default: break
        }
        
        if let itemType = itemType {
            switch itemType {
            case .busStop(let busStop):
                cell = tableView.dequeueReusableCell(withIdentifier: "busStop") as! BusStopCell
                cell.textLabel?.text = busStop.name
            case .placeResult(let placeResult):
                cell = tableView.dequeueReusableCell(withIdentifier: "searchResults") as! SearchResultsCell
                cell.textLabel?.text = placeResult.name
                cell.detailTextLabel?.text = placeResult.detail
            case .cornellDestination:
                cell = tableView.dequeueReusableCell(withIdentifier: "cornellDestinations") as! CornellDestinationCell
                cell.textLabel?.text = cornellDestinations[indexPath.row].name
                cell.detailTextLabel?.text = cornellDestinations[indexPath.row].stops
            case .seeAllStops:
                cell = tableView.dequeueReusableCell(withIdentifier: "seeAllStops")
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
        case .seeAllStops: return sections[section].items.count
        case .searchResults: return sections[section].items.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var itemType: ItemType
        let optionsVC = RouteOptionsViewController()
        let allStopsTVC = AllStopsTableViewController()
        var didSelectAllStops = false
        
        switch sections[indexPath.section].type {
        case .cornellDestination:
            itemType = .cornellDestination
        case .recentSearches, .searchResults, .seeAllStops:
            itemType = sections[indexPath.section].items[indexPath.row]
        default: itemType = ItemType.cornellDestination
        }
        switch itemType {
        case .cornellDestination:
            print("User Selected Cornell Destination")
        case .seeAllStops:
            didSelectAllStops = true
            allStopsTVC.allStops = getAllBusStops()
        case .busStop(let busStop):
            insertRecentLocation(location: busStop)
            optionsVC.searchTo = busStop
        case .placeResult(let placeResult):
            insertRecentLocation(location: placeResult)
            optionsVC.searchTo = placeResult
        }
        definesPresentationContext = false
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.endEditing(true)
        let vcToPush = didSelectAllStops ? allStopsTVC : optionsVC
        navigationController?.pushViewController(vcToPush, animated: true)
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -80.0
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return isNetworkDown ? #imageLiteral(resourceName: "noInternet") : #imageLiteral(resourceName: "emptyPin")
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = isNetworkDown ? "No Network Connection" : "Location Not Found"
        let attrs = [NSForegroundColorAttributeName: UIColor.mediumGrayColor]
        return NSAttributedString(string: title, attributes: attrs)
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let buttonTitle = isNetworkDown ? "Try Again" : ""
        let attrs = [NSForegroundColorAttributeName: UIColor.noInternetTextColor]
        return NSAttributedString(string: buttonTitle, attributes: attrs)
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        getBusStops()
    }


    
    /* Get all bus stops and store in userDefaults */
    func getBusStops() {
        Network.getAllStops().perform(withSuccess: { stops in
            self.isNetworkDown = false
            self.userDefaults.set([BusStop](), forKey: Key.UserDefaults.allBusStops)
            let allBusStops = stops.allStops
            let data = NSKeyedArchiver.archivedData(withRootObject: allBusStops)
            self.userDefaults.set(data, forKey: Key.UserDefaults.allBusStops)
            self.searchBar.isUserInteractionEnabled = true
            //self.sectionIndexes = sectionIndexesForBusStop()
        }, failure: { error in
            print("HomeVC getBusStops error:", error)
            self.isNetworkDown = true
            self.sectionIndexes = [:]
            self.searchBar.isUserInteractionEnabled = false
            self.sections = []
        })
    }
    
    /* Keyboard Functions */
    func keyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            tableView.contentInset = contentInsets
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
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

        //Crashlytics Answers
        Answers.searchBarTappedInHome()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search (e.g Balch Hall, 312 College Ave)"
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        searchBar.text = nil
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
    func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if searchText.count > 0 {
            Network.getGooglePlaces(searchText: searchText).perform(withSuccess: { responseJson in
                self.searchResultsSection = parseGoogleJSON(searchText: searchText, json: responseJson)
                self.tableView.contentOffset = .zero
                self.sections = [self.searchResultsSection]
            })
        } else {
            sections = createSections()
        }
    }
}


