//
//  SearchBarViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 2/15/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchBarView: UIView {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let northEastCoords = CLLocationCoordinate2D(latitude: 42.588371, longitude: -76.265306)
        let southWestCoords = CLLocationCoordinate2D(latitude: 42.318871, longitude: -76.684236)
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.autocompleteBounds = GMSCoordinateBounds(coordinate: northEastCoords, coordinate: southWestCoords)
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.placeholder = "Search any destination eg. 101 Cook St, Balch Hall"
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.searchBar.backgroundColor = .white
        searchController?.searchBar.tintColor = .clear
        searchController?.searchBar.isTranslucent = true
    
        addSubview((searchController?.searchBar)!)
 
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false  
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
