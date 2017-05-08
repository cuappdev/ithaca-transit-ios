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




class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DestinationDelegate {
    
    var tableView : UITableView!
    let userDefaults = UserDefaults.standard
    var searchBar: SearchBarView!
    var recentLocations: [Any] = []
    let cornellDestinations = [(name: "North Campus", stops: "RPCC, Balch Hall, Appel, Helen Newman, Jessup Field"),
                               (name: "West Campus", stops: "Baker Flagpole, Baker Flagpole (Slopeside)"),
                               (name: "Central Campus", stops: "Statler Hall, Uris Hall, Goldwin Smith Hall"),
                               (name: "Collegetown", stops: "Collegetown Crossing, Schwartz Center"),
                               (name: "Ithaca Commons", stops: "Albany @ Salvation Army, State Street, Lot 32")]
    
    func tctSectionHeaderFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 14)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recentLocations = retrieveRecentLocations()
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        view.backgroundColor = .tableBackgroundColor
        definesPresentationContext = true
        searchBar = SearchBarView()
        searchBar.resultsViewController?.destinationDelegate = self
        searchBar.searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchBar.searchController?.searchBar
        let tableViewFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - (navigationController?.navigationBar.bounds.height)!)

        tableView = UITableView(frame: tableViewFrame, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .lineColor
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "busStop")
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: "searchResults")
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: "cornellDestinations")
        view.addSubview(tableView)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.definesPresentationContext = true
        recentLocations = retrieveRecentLocations()
        tableView.reloadData()
    }

    func didSelectDestination(busStop: BusStop?, placeResult: PlaceResult?) {
        recentLocations = retrieveRecentLocations()
        tableView.reloadData()
        let optionsVC = OptionsViewController()
        if busStop != nil {
            optionsVC.searchTo = (busStop, nil)
        } else {
            optionsVC.searchTo = (nil, placeResult)
        }
        //let date1 = Time.date(from: "3:45 PM")
        //let date2 = Time.date(from: "3:52 PM")
        //let route1 = Route(departureTime: date1, arrivalTime: date2, directions: [], mainStops: ["Baker Flagpole", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
//        let routeVC = RouteDetailViewController(route: route1)
        definesPresentationContext = false
        navigationController?.pushViewController(optionsVC, animated: true)
        searchBar.searchController?.isActive = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recentLocations.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .secondaryTextColor
        header.textLabel?.font = tctSectionHeaderFont()
        header.textLabel?.text = section == 0 ? "Cornell Destinations" : "Recent Searches"
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Cornell Destinations" : "Recent Searches"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionZero = indexPath.section == 0
        let cell = getTableViewCell(indexPath: indexPath)
        
        cell.imageView?.frame = CGRect(x: 10.5, y: 5, width: 25, height: 25)
        cell.imageView?.center.y = cell.bounds.height / 2.0
        cell.textLabel?.text = sectionZero ? cornellDestinations[indexPath.row].name : getRecentLocationTitle(indexPath: indexPath)
        cell.detailTextLabel?.text = sectionZero ? cornellDestinations[indexPath.row].stops : getDetailText(reuseIdentifier: cell.reuseIdentifier!, index: indexPath.row)
        cell.textLabel?.font = tctSectionHeaderFont()
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.layoutSubviews()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 5 : retrieveRecentLocations().count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            //figure out networkCall for shiv
        }
        else {
            let optionsVC = OptionsViewController()
            if recentLocations[indexPath.row] is BusStop {
                let busStop = recentLocations[indexPath.row] as! BusStop
                optionsVC.searchTo = (busStop, nil)
            } else {
                let placeResult = recentLocations[indexPath.row] as! PlaceResult
                optionsVC.searchTo = (nil, placeResult)
            }
            definesPresentationContext = false //else going to try and present optionVC on homeVC when in optionVC
            //let date1 = Time.date(from: "3:45 PM")
            //let date2 = Time.date(from: "3:52 PM")
            //let route1 = Route(departureTime: date1, arrivalTime: date2, directions: [], mainStops: ["Baker Flagpole", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
            //let routeVC = RouteDetailViewController(route: route1)
            navigationController?.pushViewController(optionsVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getDetailText(reuseIdentifier: String, index: Int) -> String? {
        if reuseIdentifier == "searchResults" {
            let detailString = (recentLocations[index] as! PlaceResult).detail!
            let indexOfLastComma = detailString.range(of: ",", options: .backwards, range: nil, locale: nil)
            let parsedDetailString = detailString.substring(to: (indexOfLastComma?.lowerBound)!)
            return parsedDetailString
        }
        return nil
    }
    
    func getTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "cornellDestinations")! as! SearchResultsCell
        }
            
        else if indexPath.section == 1 && recentLocations[indexPath.row] is BusStop {
            return tableView.dequeueReusableCell(withIdentifier: "busStop")! as! BusStopCell
        }
        return tableView.dequeueReusableCell(withIdentifier: "searchResults")! as! SearchResultsCell
    }
    
    func getRecentLocationTitle(indexPath: IndexPath) -> String {
        if let recentLocation = recentLocations[indexPath.row] as? BusStop {
            return recentLocation.name!
        }
        return (recentLocations[indexPath.row] as! PlaceResult).name!
    }
    
    
    func retrieveRecentLocations() -> [Any] {
        if let recentLocations = userDefaults.value(forKey: "recentSearch") as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: recentLocations) as! [Any]
        }
        return [Any]()
    }
}


