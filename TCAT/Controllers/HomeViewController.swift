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
import MYTableViewIndex
import DZNEmptyDataSet

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, TableViewIndexDelegate, TableViewIndexDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    let userDefaults = UserDefaults.standard
    let cornellDestinations = [(name: "North Campus", stops: "RPCC, Balch Hall, Appel, Helen Newman, Jessup Field"),
                               (name: "West Campus", stops: "Baker Flagpole, Baker Flagpole (Slopeside)"),
                               (name: "Central Campus", stops: "Statler Hall, Uris Hall, Goldwin Smith Hall"),
                               (name: "Collegetown", stops: "Collegetown Crossing, Schwartz Center"),
                               (name: "Ithaca Commons", stops: "Albany @ Salvation Army, State Street, Lot 32")]

    var timer: Timer?
    var isNetworkDown = false
    var searchResultsSection: Section!
    var sectionIndexes: [String: Int]!
    var tableView : UITableView!
    var tableViewIndexController: TableViewIndexController!
    var initialTableViewIndexMidY: CGFloat!
    var searchBar: UISearchBar!
    var recentLocations: [ItemType] = []
    var isKeyboardVisible = false
    var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
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
        view.addSubview(tableView)
        sections = createSections()
        
        tableViewIndexController = TableViewIndexController(tableView: tableView)
        tableViewIndexController.tableViewIndex.delegate = self
        tableViewIndexController.tableViewIndex.dataSource = self
        initialTableViewIndexMidY = tableViewIndexController.tableViewIndex.indexRect().minY
        tableViewIndexController.tableViewIndex.backgroundView?.backgroundColor = .clear
        tableViewIndexController.setHidden(true, animated: false)
        setUpIndexBar(contentOffsetY: 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recentLocations = retrieveRecentLocations()
        if searchBar.showsCancelButton {
            searchBar.becomeFirstResponder()
            tableViewIndexController.setHidden(true, animated: false)
        }
        sections = createSections()
    }

    func createSections() -> [Section] {
        var allSections: [Section] = []
        let allBusStops = getAllBusStops()
        let allStopsSection = Section(type: .allStops, items: prepareAllBusStopItems(allBusStops: allBusStops))
        let recentSearchesSection = Section(type: .recentSearches, items: recentLocations)
        let cornellDestinationSection = Section(type: .cornellDestination, items: [.cornellDestination])
        allSections.append(cornellDestinationSection)
        allSections.append(recentSearchesSection)
        allSections.append(allStopsSection)
        sectionIndexes = sectionIndexesForBusStop()
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
        case .allStops: header.textLabel?.text = "All Stops"
        case .searchResults: header.textLabel?.text = nil
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section].type {
        case .cornellDestination: return "Get There Now"
        case .recentSearches: return "Recent Searches"
        case .allStops: return "All Stops"
        case .searchResults: return nil
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
        case .recentSearches, .allStops, .searchResults:
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
        case .allStops: return sections[section].items.count
        case .searchResults: return sections[section].items.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var itemType: ItemType
        let optionsVC = RouteOptionsViewController()
        
        switch sections[indexPath.section].type {
        case .cornellDestination:
            itemType = .cornellDestination
        case .recentSearches, .searchResults, .allStops:
            itemType = sections[indexPath.section].items[indexPath.row]
        default: itemType = ItemType.cornellDestination
        }
        switch itemType {
        case .cornellDestination:
            print("User Selected Cornell Destination")
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
        navigationController?.pushViewController(optionsVC, animated: true)
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -80.0
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return isNetworkDown ? #imageLiteral(resourceName: "noInternet") : #imageLiteral(resourceName: "emptyPin")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = isNetworkDown ? "No Network Connection" : "Location Not Found"
        let attrs = [NSForegroundColorAttributeName: UIColor.mediumGrayColor]
        return NSAttributedString(string: title, attributes: attrs)
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let buttonTitle = isNetworkDown ? "Try Again" : ""
        let attrs = [NSForegroundColorAttributeName: UIColor.init(red: 0.0, green: 118.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)]
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
            self.sections = self.createSections()
            self.tableViewIndexController.tableViewIndex.reloadData()
        }, failure: { error in
            print("Error when getting all stops", error)
            self.isNetworkDown = true
            self.sectionIndexes = [:]
            self.tableViewIndexController.tableViewIndex.reloadData()
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
        let contentOffsetY = scrollView.contentOffset.y
        if scrollView == tableView && searchBar.text == "" && !isKeyboardVisible {
            setUpIndexBar(contentOffsetY: contentOffsetY)
        }
    }
    
    /* SearchBar Delegates */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        tableViewIndexController.setHidden(true, animated: false)
        if sections.count > 1 {
            let scrollToSection = tableView.numberOfRows(inSection: 1) == 0 ? 0 : 1
            let secondSection = IndexPath(row: 0, section: scrollToSection)
            tableView.scrollToRow(at: secondSection, at: .top, animated: true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        searchBar.text = nil
        sections = createSections()
        for section in sections {
            print(section.type)
            print(section.items)
        }
        tableViewIndexController.setHidden(false, animated: false)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getPlaces), userInfo: ["searchText": searchText], repeats: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    /* TableViewIndex Functions */
    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
        let arrayOfKeys = Array(sectionIndexes.keys).sorted()
        return arrayOfKeys.map( { character -> UIView in
            let letter = StringItem(text: character)
            letter.tintColor = .tcatBlueColor
            return letter })
    }
    
    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) {
        let arrayOfKeys = Array(sectionIndexes.keys).sorted()
        let currentLetter = arrayOfKeys[index]
        let indexPath = IndexPath(row: sectionIndexes[currentLetter]!, section: sections.count - 1)
        // tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        if #available(iOS 10.0, *) {
            let taptic = UIImpactFeedbackGenerator(style: .light)
            taptic.prepare()
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            taptic.impactOccurred()
        } else { tableView.scrollToRow(at: indexPath, at: .top, animated: false) }
        // return true
    }
    
    func setUpIndexBar(contentOffsetY: CGFloat) {
        if let visibleRows = tableView.indexPathsForVisibleRows {
            let visibleSections = visibleRows.map({$0.section})
            if let allStopsIndex = sections.index(where: {$0.type == SectionType.allStops}), let firstAllStopCellIndexPath = visibleRows.filter({$0.section == allStopsIndex && $0.row == 1}).first {
                let secondCell = tableView.cellForRow(at: firstAllStopCellIndexPath)
                let newYPosition = view.convert(tableViewIndexController.tableViewIndex.indexRect(), from: tableView).minY
                if ((newYPosition * -1.0) < (secondCell?.frame.minY)! - view.bounds.midY) {
                    let offset = (secondCell?.frame.minY)! - initialTableViewIndexMidY - contentOffsetY
                    tableViewIndexController.tableViewIndex.indexOffset = UIOffset(horizontal: 0.0, vertical: offset)
                    tableViewIndexController.setHidden(!visibleSections.contains(allStopsIndex), animated: true)
                }
            }
        }
    }
    
    /* Get Search Results */
    func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if searchText.characters.count > 0 {
            Network.getGooglePlaces(searchText: searchText).perform(withSuccess: { responseJson in
                self.searchResultsSection = parseGoogleJSON(searchText: searchText, json: responseJson)
                self.tableView.contentOffset = .zero
                self.sections = [self.searchResultsSection]
                self.tableViewIndexController.setHidden(true, animated: false)
                //if !self.sections[0].items.isEmpty {
                    //self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false) }
            })
        } else {
            sections = createSections()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
            self.tableViewIndexController.setHidden(false, animated: false)
        }
    }
}


