//
//  SearchBarView.swift
//  TCAT
//
//  Created by Austin Astorga on 2/15/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class SearchBarView: UIView, UISearchControllerDelegate {

    var resultsViewController: SearchResultsViewController?
    var searchController: UISearchController?

    init(searchBarCancelDelegate: SearchBarCancelDelegate? = nil, destinationDelegate: DestinationDelegate? = nil) {
        super.init(frame: .zero)

        // Search Bar Customization
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: Colors.black], for: .normal)

        resultsViewController = SearchResultsViewController(
            searchBarCancelDelegate: searchBarCancelDelegate,
            destinationDelegate: destinationDelegate
        )
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.delegate = resultsViewController
        resultsViewController?.searchBar = searchController?.searchBar

        let textFieldInsideSearchBar = searchController?.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = Colors.backgroundWash
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(
            string: Constants.General.searchPlaceholder,
            attributes: [.foregroundColor: Colors.dividerTextField]
        )

        searchController?.searchBar.tintColor = .clear
        searchController?.delegate = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.hidesNavigationBarDuringPresentation = false

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
