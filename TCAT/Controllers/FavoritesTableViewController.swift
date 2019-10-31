//
//  FavoritesTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 11/17/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import FutureNova

protocol FavoritesSelectionDelegate: class {
    func didAddNewFavorite()
}

class FavoritesTableViewController: UIViewController {

    private var searchBar = UISearchBar()
    private var tableView: UITableView!

    private var timer: Timer?
    private let networking: Networking = URLSession.shared.request
    private var resultsSection = Section.searchResults(items: []) {
        didSet {
            tableView.reloadData()
        }
    }

    /// Handler for favorite selection
    var didAddFavorite: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.white
        title = Constants.Titles.favorite
        let systemItem: UIBarButtonItem.SystemItem = .cancel
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: systemItem,
                                                            target: self,
                                                            action: #selector(dismissVC))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            CustomNavigationController.buttonTitleTextAttributes, for: .normal
        )

        setupTableView()
        setupConstraints()
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: Constants.Cells.placeIdentifier)
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
        tableView.reloadEmptyDataSet()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.endEditing(true)
    }

    @objc private func dismissVC() {
        dismiss(animated: true)
    }
}

// MARK: - Table view data source
extension FavoritesTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsSection.getItems().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.placeIdentifier, for: indexPath) as? PlaceTableViewCell
            else { return UITableViewCell()}
        if let place = resultsSection.getItem(at: indexPath.row) {
            cell.configure(for: place)
        }
        return cell
    }
}

// MARK: - Table view delegate
extension FavoritesTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        searchBar.isTranslucent = true
        searchBar.placeholder = Constants.General.favoritesPlaceholder
        searchBar.backgroundImage = UIImage()
        searchBar.alpha = 1.0
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = Colors.backgroundWash
        searchBar.backgroundColor = Colors.white
        searchBar.delegate = self
        return searchBar
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryView = UIActivityIndicatorView()
        tableView.deselectRow(at: indexPath, animated: true)
        if let searchText = searchBar.text {
            let payload = SearchResultSelectedPayload(
                searchText: searchText,
                selectedIndex: indexPath.row,
                totalResults: resultsSection.getItems().count
            )
            Analytics.shared.log(payload)
        }
        if let place = resultsSection.getItem(at: indexPath.row) {
            Global.shared.insertPlace(for: Constants.UserDefaults.favorites, place: place, bottom: true)
            didAddFavorite?()
            dismissVC()
        }
    }
}

// MARK: - Empty Data Set
extension FavoritesTableViewController: DZNEmptyDataSetSource {
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -80
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "search-large")
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let title = Constants.General.searchForDestination
        return NSAttributedString(string: title, attributes: [.foregroundColor: Colors.metadataIcon])
    }
}

// MARK: - Search
extension FavoritesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2,
                                     target: self,
                                     selector: #selector(getPlaces),
                                     userInfo: ["searchText": searchText],
                                     repeats: false)
    }

    /// Get Search Results
    @objc func getPlaces(timer: Timer) {
        if let userInfo = timer.userInfo as? [String: String],
            let searchText = userInfo["searchText"],
            !searchText.isEmpty {
            SearchManager.shared.performLookup(for: searchText) { [weak self] (searchResults, error) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    if let error = error {
                        self.printClass(context: "SearchManager lookup error", message: error.localizedDescription)
                        self.resultsSection = Section.recentSearches(items: [])
                        return
                    }
                    self.resultsSection = Section.searchResults(items: searchResults)
                }
            }
        } else {
            resultsSection = Section.searchResults(items: [])
        }
    }

}
