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

struct Section {
    let type: SectionType
    var items: [ItemType]
    
}

enum SectionType {
    case CornellDestination
    case RecentSearches
    case AllStops
    case SearchResults
}

enum ItemType {
    case BusStop(BusStop)
    case PlaceResult(PlaceResult)
    case CornellDestination
}


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var cornellDestinationSection: Section!
    var recentSearchesSection: Section!
    var allStopsSection: Section!
    var searchResultsSection: Section!
    var timer: Timer?
    var tableView : UITableView!
    let userDefaults = UserDefaults.standard
    var searchBar: UISearchBar!
    var recentLocations: [ItemType] = []
    let cornellDestinations = [(name: "North Campus", stops: "RPCC, Balch Hall, Appel, Helen Newman, Jessup Field"),
                               (name: "West Campus", stops: "Baker Flagpole, Baker Flagpole (Slopeside)"),
                               (name: "Central Campus", stops: "Statler Hall, Uris Hall, Goldwin Smith Hall"),
                               (name: "Collegetown", stops: "Collegetown Crossing, Schwartz Center"),
                               (name: "Ithaca Commons", stops: "Albany @ Salvation Army, State Street, Lot 32")]
    let json = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "config", withExtension: "json")!))
    
    
    func tctSectionHeaderFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 14)
    }
    
    var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        tableView.separatorColor = .lineColor
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "busStop")
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: "searchResults")
        tableView.register(CornellDestinationCell.self, forCellReuseIdentifier: "cornellDestinations")
        view.addSubview(tableView)
        
        
        cornellDestinationSection = Section(type: .CornellDestination, items: [.CornellDestination])
        let allBusStops = getAllBusStops()
        allStopsSection = Section(type: .AllStops, items: prepareAllBusStopItems(allBusStops: allBusStops))
        recentSearchesSection = Section(type: .RecentSearches, items: recentLocations)
        searchResultsSection = Section(type: .SearchResults, items: [])
        sections = recentLocations.isEmpty ? [cornellDestinationSection, allStopsSection] : [cornellDestinationSection, recentSearchesSection, allStopsSection]
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.definesPresentationContext = true
        recentLocations = retrieveRecentLocations()
        tableView.reloadData()
    }
    
    func prepareAllBusStopItems(allBusStops: [BusStop]) -> [ItemType] {
        var itemArray: [ItemType] = []
        for bus in allBusStops {
            itemArray.append(.BusStop(BusStop(name: bus.name!, lat: bus.lat!, long: bus.long!)))
        }
        return itemArray
    }
    
    func getAllBusStops() -> [BusStop] {
        if let allBusStops = userDefaults.value(forKey: "allBusStops") as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: allBusStops) as! [BusStop]
        }
        return [BusStop]()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        //let secondSection = IndexPath(row: 0, section: 1)
        //tableView.scrollToRow(at: secondSection, at: .top, animated: true)
        tableView.beginUpdates()
        tableView.deleteSections([0], with: .top)
        sections.remove(at: 0)
        tableView.endUpdates()
        
        //tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        sections = recentLocations.isEmpty ? [allStopsSection] : [recentSearchesSection, allStopsSection]
        tableView.beginUpdates()
        sections.insert(cornellDestinationSection, at: 0)
        tableView.insertSections([0], with: .top)
        tableView.endUpdates()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getPlaces), userInfo: ["searchText": searchText], repeats: false)
    }
    
    func getPlaces(timer: Timer) {
        print("In Get Places")
        var itemTypes: [ItemType] = []
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        
        if searchText != "" {
        let filteredBusStops = getAllBusStops().filter({(item: BusStop) -> Bool in
            let stringMatch = item.name?.lowercased().range(of: searchText.lowercased())
            return stringMatch != nil
        })
        let updatedOrderBusStops = sortFilteredBusStops(busStops: filteredBusStops, letter: searchText.capitalized.characters.first!)
        itemTypes = itemTypes + updatedOrderBusStops.map( {ItemType.BusStop($0)} )
        let urlReadySearch = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let stub = "https://maps.googleapis.com/maps/api/place/autocomplete/json?location=42.4440,-76.5019&radius=24140&strictbounds&input="
        let apiKey = "&key=\(json["google-places"].stringValue)"
        let searchUrlString = stub + urlReadySearch + apiKey
        Alamofire.request(searchUrlString).responseJSON {response in
            if  response.result.value != nil {
                let resultJson = JSON(response.result.value!)
                for result in resultJson["predictions"].array! {
                    let placeResult = PlaceResult(name: result["structured_formatting"]["main_text"].stringValue, detail: result["structured_formatting"]["secondary_text"].stringValue, placeID: result["place_id"].stringValue)
                    //check if name matches exactly a bus stop name
                    let isPlaceABusStop = filteredBusStops.contains(where: {(stop) -> Bool in
                        placeResult.name!.contains(stop.name!)
                    })
                    if !isPlaceABusStop {
                        itemTypes.append(ItemType.PlaceResult(placeResult))
                    }
                }
                self.searchResultsSection.items = itemTypes
                self.sections = [self.searchResultsSection]
                self.tableView.reloadData()
            }
        }
    }
        else {
            sections = recentLocations.isEmpty ? [allStopsSection] : [recentSearchesSection, allStopsSection]
        }
    }
    
func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
}

func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.textLabel?.textColor = .secondaryTextColor
    header.textLabel?.font = tctSectionHeaderFont()
    header.textLabel?.text = section == 0 ? "Cornell Destinations" : "Recent Searches"
    switch sections[section].type {
    case .CornellDestination: header.textLabel?.text = "Cornell Destinations"
    case .RecentSearches: header.textLabel?.text = "Recent Searches"
    case .AllStops: header.textLabel?.text = "All Stops"
    case .SearchResults: header.textLabel?.text = nil
    }
}

func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch sections[section].type {
    case .CornellDestination: return "Cornell Destinations"
    case .RecentSearches: return "Recent Searches"
    case .AllStops: return "All Stops"
    case .SearchResults: return nil
    }
    
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50.0
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var itemType : ItemType?
    var cell: UITableViewCell!
    
    switch sections[indexPath.section].type {
    case .CornellDestination:
        itemType = .CornellDestination
    case .RecentSearches, .AllStops, .SearchResults:
        itemType = sections[indexPath.section].items[indexPath.row]
    }
    
    if let itemType = itemType {
        switch itemType {
        case .BusStop(let busStop):
            cell = tableView.dequeueReusableCell(withIdentifier: "busStop") as! BusStopCell
            cell.textLabel?.text = busStop.name
        case .PlaceResult(let placeResult):
            cell = tableView.dequeueReusableCell(withIdentifier: "searchResults") as! SearchResultsCell
            cell.textLabel?.text = placeResult.name
            cell.detailTextLabel?.text = placeResult.detail
        case .CornellDestination:
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
    case .CornellDestination: return cornellDestinations.count
    case .RecentSearches: return recentLocations.count
    case .AllStops: return sections[section].items.count
    case .SearchResults: return sections[section].items.count
    }
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var itemType: ItemType
    let optionsVC = OptionsViewController()
    
    switch sections[indexPath.section].type {
    case .CornellDestination:
        itemType = .CornellDestination
    case .RecentSearches, .SearchResults, .AllStops:
        itemType = sections[indexPath.section].items[indexPath.row]
    }
    
    switch itemType {
    case .CornellDestination:
        print("User Selected Cornell Destination")
    case .BusStop(let busStop):
        print("Selected Bus Stop: ", busStop.name)
    //optionsVC.searchTo(.busstop, busStop as? Any)
    case .PlaceResult(let placeResult):
        print("Selected Place Result: ", placeResult.name)
        //optionsVC.searchTo(.placeResult, placeResult)
    }
    
    //navigationController?.pushViewController(optionsVC, animated: true)
    
    tableView.deselectRow(at: indexPath, animated: true)
}

func retrieveRecentLocations() -> [ItemType] {
    if let recentLocations = userDefaults.value(forKey: "recentSearch") as? Data {
        let recentSearches = NSKeyedUnarchiver.unarchiveObject(with: recentLocations) as! [Any]
        var itemTypes: [ItemType] = []
        for search in recentSearches {
            if let busStop = search as? BusStop {
                itemTypes.append(.BusStop(busStop))
            }
            if let searchResult = search as? PlaceResult {
                itemTypes.append(.PlaceResult(searchResult))
            }
        }
        return itemTypes
    }
    return [ItemType]()
}
}


