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

protocol DestinationDelegate {
    func didSelectDestination(busStop: BusStop?, placeResult: PlaceResult?)
}

class SearchResultsTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    let userDefaults = UserDefaults.standard
    var destinationDelegate: DestinationDelegate?
    var busStops: [BusStop] = []
    let busJson = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "MOCK_DATA", withExtension: "json")!))
    var isRecentLocationsEmpty: Bool!
    var placesTimer: Timer!
    let json = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "config", withExtension: "json")!))
    var timer: Timer? = nil
    var searchString = ""
    var searchResults : [Any] = []
    var recentLocations: [Any] = []
    var searchBar: UISearchBar? = nil
    
    func tctSectionHeaderFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 14)
    }
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBusStops()
        recentLocations = retrieveRecentLocations()
        extendedLayoutIncludesOpaqueBars = true
        isRecentLocationsEmpty = recentLocations.isEmpty
        
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "busStops")
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: "searchResults")
        tableView.tableFooterView = UIView()
        placesTimer = Timer(timeInterval: 1, target: self, selector: #selector(getPlaces), userInfo: nil, repeats: false)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func createBusStops() {
        for stop in busJson.array! {
            let busStop = BusStop(name: stop["name"].stringValue, lat: stop["lat"].doubleValue, long: stop["long"].doubleValue)
            busStops.append(busStop)
        }
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
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !isSearchEmpty() { return 1 }
        return isRecentLocationsEmpty! ? 1 : 2
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !isSearchEmpty() { return searchResults.count}
        return section == 0 && !isRecentLocationsEmpty ? recentLocations.count : busStops.count
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .secondaryTextColor
        header.textLabel?.font = tctSectionHeaderFont()
        header.textLabel?.text = section == 0 && !isRecentLocationsEmpty ? "Recent Searches" : "All Stops"
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearchEmpty() { return section == 0 && !isRecentLocationsEmpty ? "Recent Searches" : "All Stops" }
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && tableView.numberOfSections == 2 {
            if let placeResult = recentLocations[indexPath.row] as? PlaceResult {
                destinationDelegate?.didSelectDestination(busStop: nil, placeResult: placeResult)
            } else {
                destinationDelegate?.didSelectDestination(busStop: recentLocations[indexPath.row] as? BusStop, placeResult: nil)
            }
            
        } else {
            if isSearchEmpty() { destinationDelegate?.didSelectDestination(busStop: busStops[indexPath.row], placeResult: nil)
                insertRecentLocation(location: busStops[indexPath.row])
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
        cell.textLabel?.text = getLabelText(reuseIdentifier: cell.reuseIdentifier!, index: indexPath.row)
        cell.detailTextLabel?.text = getDetailText(reuseIdentifier: cell.reuseIdentifier!, index: indexPath.row)
        cell.textLabel?.font = tctSectionHeaderFont()
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        
        return cell
    }
    
    
    func getDetailText(reuseIdentifier: String, index: Int) -> String? {
        let placeResultArray = reuseIdentifier == "searchResults" && isSearchEmpty() && !isRecentLocationsEmpty ? recentLocations : searchResults
        if reuseIdentifier == "searchResults" {
            let detailString = (placeResultArray[index] as! PlaceResult).detail!
            let indexOfLastComma = detailString.range(of: ",", options: .backwards, range: nil, locale: nil)
            let parsedDetailString = detailString.substring(to: (indexOfLastComma?.lowerBound)!)
            return parsedDetailString
        }
        return nil
    }
    
    
    func getLabelText(reuseIdentifier: String, index: Int) -> String {
        let placeResultArray = reuseIdentifier == "searchResults" && isSearchEmpty() && !isRecentLocationsEmpty ? recentLocations : searchResults
        if reuseIdentifier == "recentSearches" {
            if let stop = recentLocations[index] as? BusStop {
                return stop.name!
            } else { return (recentLocations[index] as! PlaceResult).name! }
        } else if reuseIdentifier == "busStops"{
            return isSearchEmpty() ? busStops[index].name! : (searchResults[index] as! BusStop).name!
        }
        return (placeResultArray[index] as! PlaceResult).name!
    }
    
    
    func getTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        if isSearchEmpty() {
            return indexPath.section == 0 && !isRecentLocationsEmpty && recentLocations[indexPath.row] is PlaceResult ? tableView.dequeueReusableCell(withIdentifier: "searchResults") as! SearchResultsCell : tableView.dequeueReusableCell(withIdentifier: "busStops") as! BusStopCell
        }
        return searchResults[indexPath.row] is PlaceResult ? tableView.dequeueReusableCell(withIdentifier: "searchResults") as! SearchResultsCell : tableView.dequeueReusableCell(withIdentifier: "busStops") as! BusStopCell
    }
    
    
    func insertRecentLocation(location: Any) {
        let recentLocations = retrieveRecentLocations()
        var updatedRecentLocations = [location] + recentLocations
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
    
    
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchString = ""
        searchResults = []
        tableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getPlaces), userInfo: ["searchText": searchText], repeats: false)
    }
    
    
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
        searchResults = searchResults + filteredBusStops
        
        if searchText == "" {
            searchString = ""
            tableView.reloadData()
        } else {
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
                        if !isPlaceABusStop { self.searchResults.append(placeResult) }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}
