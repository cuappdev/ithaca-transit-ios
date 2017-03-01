//
//  HomeViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 2/8/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import GooglePlaces

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, GMSAutocompleteResultsViewControllerDelegate {
    
    var tableView : UITableView!
    let userDefaults = UserDefaults.standard
    
    //ADD TO COLOR EXTENSION
    let headerTextColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    let tcatOrange = UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1.0)
    
    var searchBar: SearchBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "App Name"
        navigationController?.navigationBar.barTintColor = tcatOrange
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        view.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
        
        //To Implement the Search Bar within a vie
        searchBar = SearchBarView(frame: CGRect(x: 0, y: 65.0, width: view.bounds.width, height: 45.0))
        searchBar.resultsViewController?.delegate = self
        view.addSubview(searchBar)
        
        
        //UITableView Set Up
        let tableViewFrame = CGRect(x: 0, y: searchBar.frame.maxY, width: view.bounds.width, height: view.bounds.height - searchBar.bounds.height)
        tableView = UITableView(frame: tableViewFrame, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }

 
    //Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        //header.textLabel?.font = UIFont(name: "SFUIDisplay-Regular", size: 12)!
        header.textLabel?.textColor = headerTextColor
        header.textLabel?.text = section == 0 ? "Cornell Destinations" : "Recent Searches"
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Cornell Destinations" : "Recent Searches"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 110.5 : 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return UITableViewCell()
        }
        let locations = retrieveRecentLocations()
        var cell = tableView.dequeueReusableCell(withIdentifier: "recentLocation")
        if cell == nil {
            cell = UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: "recentLocation")
        }
        cell?.textLabel?.text = locations[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : retrieveRecentLocations().count
    }
    
    //Collectionview
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
   
    //Google Places
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




