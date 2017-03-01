//
//  SearchBarViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 2/15/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import GooglePlaces


class SearchBarView: UIView, UISearchControllerDelegate {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Search Bar Customization
        UISearchBar.appearance().setImage(UIImage(named: "search"), for: .search, state: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.black], for: .normal)
        
        //Google Places Soft Bounds
        let northEastCoords = CLLocationCoordinate2D(latitude: 42.588371, longitude: -76.265306)
        let southWestCoords = CLLocationCoordinate2D(latitude: 42.318871, longitude: -76.684236)
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.autocompleteBounds = GMSCoordinateBounds(coordinate: northEastCoords, coordinate: southWestCoords)
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let textFieldInsideSearchBar = searchController?.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(string: "Search (e.g Balch Hall, 312 College Ave)", attributes: [NSForegroundColorAttributeName: UIColor(red: 210/255, green: 213/255, blue: 217/255, alpha: 1.0)])
        
        searchController?.searchBar.backgroundColor = .clear
        searchController?.searchBar.tintColor = .clear
        searchController?.searchBar.isTranslucent = true
        searchController?.delegate = self
        addSubview((searchController?.searchBar)!)
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
