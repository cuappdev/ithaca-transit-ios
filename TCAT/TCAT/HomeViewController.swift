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
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    var tableView : UITableView!
    
    //ADD TO COLOR EXTENSION
    let headerTextColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    let tcatOrange = UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "App Name"
        navigationController?.navigationBar.barTintColor = tcatOrange
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        view.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        //general bounds for now. Not sure how far tcat goes. They are soft bounds
        let northEastCoords = CLLocationCoordinate2D(latitude: 42.588371, longitude: -76.265306)
        let southWestCoords = CLLocationCoordinate2D(latitude: 42.318871, longitude: -76.684236)
        resultsViewController?.autocompleteBounds = GMSCoordinateBounds(coordinate: northEastCoords, coordinate: southWestCoords)
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.placeholder = "Search any destination eg. 101 Cook St, Balch Hall"
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.searchBar.backgroundColor = .white
        searchController?.searchBar.tintColor = .clear
        searchController?.searchBar.isTranslucent = true
        
    
        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: view.bounds.width, height: 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        //UITableView Set Up
        let tableViewFrame = CGRect(x: 0, y: subView.frame.maxY, width: view.bounds.width, height: view.bounds.height - subView.bounds.height)
        tableView = UITableView(frame: tableViewFrame, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 10
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
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}




