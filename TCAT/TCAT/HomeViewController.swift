//
//  HomeViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 2/8/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import GooglePlaces

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,GMSAutocompleteResultsViewControllerDelegate {
    
    var tableView : UITableView!
    let userDefaults = UserDefaults.standard
    var searchBar: SearchBarView!
    
    //ADD TO COLOR EXTENSION
    let headerTextColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    let backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
    let tableViewSeparatorColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        view.backgroundColor = backgroundColor
        
        searchBar = SearchBarView()
        searchBar.resultsViewController?.delegate = self

        navigationItem.titleView = searchBar.searchController?.searchBar
    

        //UITableView Set Up
        let tableViewFrame = CGRect(x: 0, y: searchBar.frame.maxY, width: view.bounds.width, height: view.bounds.height - searchBar.bounds.height)

        tableView = UITableView(frame: tableViewFrame, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = tableViewSeparatorColor
        view.addSubview(tableView)
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return retrieveRecentLocations().count == 0 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = headerTextColor
        header.textLabel?.text = section == 0 ? "Cornell Destinations" : "Recent Searches"
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Cornell Destinations" : "Recent Searches"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 60.0 : 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //Stub for now
            return UITableViewCell()
        }
        let locations = retrieveRecentLocations()
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentLocation") == nil ? RecentSearchCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: "recentLocation") : tableView.dequeueReusableCell(withIdentifier: "recentLocation")!
        
        cell.imageView?.frame = (frame: CGRect(x: 5, y: 5, width: 25, height: 25))
        cell.imageView?.image = #imageLiteral(resourceName: "search")

        cell.textLabel?.text = locations[indexPath.row].name
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 5 : retrieveRecentLocations().count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Google Places Methods
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchBar.searchController?.isActive = false
        // Do something with the selected place.
        let resultLocation = SearchLocation(name: place.name, latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        insertRecentLocation(location: resultLocation)
    }
    
    func retrieveRecentLocations() -> [SearchLocation] {
        if let recentLocations = userDefaults.value(forKey: "recentLocations") as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: recentLocations) as! [SearchLocation]
        }
        return [SearchLocation]()
    }
    
    func insertRecentLocation(location: SearchLocation) {
        let currentLocations = retrieveRecentLocations()
        var updatedLocations = [location] + currentLocations
        if updatedLocations.count > 8 {
            updatedLocations.remove(at: updatedLocations.count - 1)
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: updatedLocations)
        userDefaults.set(data, forKey: "recentLocations")
        tableView.reloadData()
    }
    
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
    
    
    //Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


