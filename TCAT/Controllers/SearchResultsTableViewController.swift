//
//  SearchResultsTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreLocation
import DZNEmptyDataSet

protocol DestinationDelegate {
    func didSelectDestination(busStop: BusStop?, placeResult: PlaceResult?)
}
protocol SearchBarCancelDelegate {
    func didCancel()
}


class SearchResultsTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    let userDefaults = UserDefaults.standard
    var destinationDelegate: DestinationDelegate?
    var searchBarCancelDelegate: SearchBarCancelDelegate?
    var busStops: [BusStop] = []
    var isRecentLocationsEmpty: Bool!
    var placesTimer: Timer!
    let json = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "config", withExtension: "json")!))
    var timer: Timer?
    var searchString = ""
    var searchResults : [Any] = []
    var recentLocations: [Any] = []
    var searchBar: UISearchBar?
    var noSearchResults: Bool?
    var sections : [(index: Int, length :Int, title: String)] = []
    var sectionExtraIndex: Int!
    
    func tctSectionHeaderFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 14)
    }
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("searchResultsVC: \(self.isBeingPresented)")
        busStops = getAllBusStops()
        recentLocations = retrieveRecentLocations()
        isRecentLocationsEmpty = recentLocations.isEmpty
        sectionExtraIndex = !isRecentLocationsEmpty ? 1 : 0
        formatSections()
        extendedLayoutIncludesOpaqueBars = true
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "busStops")
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: "searchResults")
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        placesTimer = Timer(timeInterval: 1, target: self, selector: #selector(getPlaces), userInfo: nil, repeats: false)
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexColor = .primaryTextColor
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .tableBackgroundColor
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* TableView Methods */
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !isSearchEmpty() { return 1 }
        return sections.count + sectionExtraIndex
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noSearchResults != nil && noSearchResults! { return 0 }
        else if !isSearchEmpty() { return searchResults.count}
        else if tableView.numberOfSections == sections.count {
            return sections[section].length
        } else {
            return section == 0 ? recentLocations.count : sections[section - sectionExtraIndex].length
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .secondaryTextColor
        header.textLabel?.font = tctSectionHeaderFont()
        header.textLabel?.text = section == 0 && !isRecentLocationsEmpty ? "Recent Searches" : sections[section - sectionExtraIndex].title
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearchEmpty() { return section == 0 && !isRecentLocationsEmpty ? "Recent Searches" : sections[section - sectionExtraIndex].title }
        return nil
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let azArray = sections.map( { $0.title })
        let sectionTitles = !isRecentLocationsEmpty ? ["{search}"] + azArray : azArray
        return isSearchEmpty() ? sectionTitles : nil
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 && isSearchEmpty() && !isRecentLocationsEmpty {
            insertRecentLocation(location: recentLocations[indexPath.row])
            if let placeResult = recentLocations[indexPath.row] as? PlaceResult {
                destinationDelegate?.didSelectDestination(busStop: nil, placeResult: placeResult)
            } else {
                destinationDelegate?.didSelectDestination(busStop: recentLocations[indexPath.row] as? BusStop, placeResult: nil)
            }
        } else {
            if isSearchEmpty() {
                insertRecentLocation(location: busStops[sections[indexPath.section - sectionExtraIndex].index + indexPath.row])
                destinationDelegate?.didSelectDestination(busStop: busStops[sections[indexPath.section - sectionExtraIndex].index + indexPath.row], placeResult: nil)
            }
            else {
                insertRecentLocation(location: searchResults[indexPath.row])
                if let busStop = searchResults[indexPath.row] as? BusStop {
                    destinationDelegate?.didSelectDestination(busStop: busStop, placeResult: nil)
                } else {
                    destinationDelegate?.didSelectDestination(busStop: nil, placeResult: searchResults[indexPath.row] as? PlaceResult)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getTableViewCell(indexPath: indexPath)
        cell.textLabel?.text = getLabelText(reuseIdentifier: cell.reuseIdentifier!, index: indexPath.row, section: indexPath.section)
        cell.detailTextLabel?.text = getDetailText(reuseIdentifier: cell.reuseIdentifier!, index: indexPath.row)
        cell.textLabel?.font = tctSectionHeaderFont()
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        
        return cell
    }
    
    /* cellForRowAt Helpers */
    func getTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        
        if isSearchEmpty() {
            return indexPath.section == 0 && !isRecentLocationsEmpty && recentLocations[indexPath.row] is PlaceResult ? tableView.dequeueReusableCell(withIdentifier: "searchResults") as! SearchResultsCell : tableView.dequeueReusableCell(withIdentifier: "busStops") as! BusStopCell
        }
        return searchResults[indexPath.row] is PlaceResult ? tableView.dequeueReusableCell(withIdentifier: "searchResults") as! SearchResultsCell : tableView.dequeueReusableCell(withIdentifier: "busStops") as! BusStopCell
    }
    
    func getLabelText(reuseIdentifier: String, index: Int, section: Int) -> String {
        let placeResultArray = reuseIdentifier == "searchResults" && isSearchEmpty() && !isRecentLocationsEmpty ? recentLocations : searchResults
        if reuseIdentifier == "recentSearches" {
            if let stop = recentLocations[index] as? BusStop {
                return stop.name!
            } else { return (recentLocations[index] as! PlaceResult).name! }
        } else if reuseIdentifier == "busStops"{
            if isSearchEmpty() { return !isRecentLocationsEmpty && section == 0 ? (recentLocations[index] as! BusStop).name! : busStops[sections[section - sectionExtraIndex].index + index].name!} else { return (searchResults[index] as! BusStop).name! }
        }
        return (placeResultArray[index] as! PlaceResult).name!
    }
    
    func getDetailText(reuseIdentifier: String, index: Int) -> String? {
        let placeResultArray = reuseIdentifier == "searchResults" && isSearchEmpty() && !isRecentLocationsEmpty ? recentLocations : searchResults
        if reuseIdentifier == "searchResults" {
            let detailString = (placeResultArray[index] as! PlaceResult).detail!
            let indexOfLastComma = detailString.range(of: ",", options: .backwards, range: nil, locale: nil)
            if indexOfLastComma != nil {
                let parsedDetailString = detailString.substring(to: (indexOfLastComma?.lowerBound)!)
                return parsedDetailString
            }
            return detailString
        }
        return nil
    }
    
    /* Search Bar Methods */
    func clearSearch() {
        searchString = ""
        searchResults = []
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        tableView.reloadData()
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        if searchController.searchBar.text == "" {
            clearSearch()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearSearch()
        searchBarCancelDelegate?.didCancel()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getPlaces), userInfo: ["searchText": searchText], repeats: false)
    }
    
    /* Networking Methods */
    func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        fetchGooglePlaces(searchText: searchText)
    }
    
    func fetchGooglePlaces(searchText: String) {
        searchResults = []
        let filteredBusStops = busStops.filter({(item: BusStop) -> Bool in
            let stringMatch = item.name?.lowercased().range(of: searchText.lowercased())
            return stringMatch != nil
        })
        if searchText == "" {
            searchString = ""
            noSearchResults = nil
            tableView.reloadData()
        } else {
            noSearchResults = true
            let updatedOrderBusStops = sortFilteredBusStops(busStops: filteredBusStops, letter: searchText.capitalized.characters.first!)
            searchResults = searchResults + updatedOrderBusStops
            let urlReadySearch = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let stub = "https://maps.googleapis.com/maps/api/place/autocomplete/json?location=42.4440,-76.5019&radius=24140&strictbounds&input="
            let apiKey = "&key=\(json["google-places"].stringValue)"
            let searchUrlString = stub + urlReadySearch + apiKey
            Alamofire.request(searchUrlString).responseJSON {response in
                if  response.result.value != nil {
                    let resultJson = JSON(response.result.value!)
                    for result in resultJson["predictions"].array! {
                        self.noSearchResults = false
                        let placeResult = PlaceResult(name: result["structured_formatting"]["main_text"].stringValue, detail: result["structured_formatting"]["secondary_text"].stringValue, placeID: result["place_id"].stringValue)
                        //check if name matches exactly a bus stop name
                        let isPlaceABusStop = filteredBusStops.contains(where: {(stop) -> Bool in
                            placeResult.name!.contains(stop.name!)
                        })
                        if !isPlaceABusStop { self.searchResults.append(placeResult) }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    /* No Search Results Methods */
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -80.0
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "emptyPin")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let locationNotFound = "Location not found"
        let attrs = [NSForegroundColorAttributeName: UIColor.mediumGrayColor]
        return NSAttributedString(string: locationNotFound, attributes: attrs)
    }
    
    /* Helper Functions */
    func formatSections() {
        var index = 0
        for x in 0..<busStops.count {
            let commonPreix = busStops[x].name?.commonPrefix(with: busStops[index].name!, options: .caseInsensitive)
            if commonPreix?.characters.count == 0 || x + 1 == busStops.count {
                let string = busStops[index].name?.uppercased()
                let firstCharacter = string?[(string?.startIndex)!]
                let title = String(describing: firstCharacter!)
                let length = x + 1 == busStops.count ? busStops.count - index : x - index
                let newSection = (index: index, length: length, title: title)
                sections.append(newSection)
                index = x
            }
        }
    }
    
    func getAllBusStops() -> [BusStop] {
        if let allBusStops = userDefaults.value(forKey: "allBusStops") as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: allBusStops) as! [BusStop]
        }
        return [BusStop]()
    }
    
    func isSearchEmpty() -> Bool {
        return searchString == ""
    }
    
    func retrieveRecentLocations() -> [Any] {
        if let recentLocations = userDefaults.value(forKey: "recentSearch") as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: recentLocations) as! [Any]
        }
        return [Any]()
    }
    
    func insertRecentLocation(location: Any) {
        let recentLocations = retrieveRecentLocations()
        var filteredLocations = [Any]()
        if location is BusStop {
            filteredLocations = recentLocations.filter({ !areObjectsEqual(type: BusStop.self, a: location, b: $0)})
        } else {
           filteredLocations = recentLocations.filter({ !areObjectsEqual(type: PlaceResult.self, a: location, b: $0)})
        }
        print(filteredLocations.map({$0}))
        var updatedRecentLocations = [location] + filteredLocations
        if updatedRecentLocations.count > 8 { updatedRecentLocations.remove(at: updatedRecentLocations.count - 1)}
        let data = NSKeyedArchiver.archivedData(withRootObject: updatedRecentLocations)
        userDefaults.set(data, forKey: "recentSearch")
    }
    
    func addToRecentSearches() {
        let recentSearchArray = userDefaults.array(forKey: "recentSearch") as! [String]
        let filteredRecentSearchArray = recentSearchArray.filter({$0 != searchString})
        var updatedRecentSearchArray = [searchString] + filteredRecentSearchArray
        if updatedRecentSearchArray.count > 8 { updatedRecentSearchArray.remove(at: 8) }
        userDefaults.set(updatedRecentSearchArray, forKey: "recentSearch")
        recentLocations = retrieveRecentLocations()
    }
    
    func sortFilteredBusStops(busStops: [BusStop], letter: Character) -> [BusStop]{
        var nonLetterArray = [BusStop]()
        var letterArray = [BusStop]()
        for stop in busStops {
            if stop.name?.characters.first! == letter {
                letterArray.append(stop)
            } else {
                nonLetterArray.append(stop)
            }
        }
        return letterArray + nonLetterArray
    }
}
