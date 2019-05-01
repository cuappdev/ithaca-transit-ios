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

class FavoritesTableViewController: UITableViewController {

    var fromOnboarding = false
    var timer: Timer?
    var searchBar = UISearchBar()
    var resultsSection: Section! {
        didSet {
            tableView.reloadData()
        }
    }
    private let networking: Networking = URLSession.shared.request

    override func viewDidLoad() {
        super.viewDidLoad()

        title = fromOnboarding ? Constants.Titles.favorites : Constants.Titles.favorite
        let systemItem: UIBarButtonItem.SystemItem = fromOnboarding ? .done : .cancel
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: systemItem,
                                                            target: self,
                                                            action: #selector(dismissVC))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            CustomNavigationController.buttonTitleTextAttributes, for: .normal
        )

        resultsSection = Section(type: .searchResults, items: [Place]())

        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: Constants.Cells.placeIdentifier)
        tableView.emptyDataSetSource = self
        //tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.endEditing(true)
    }

    private func getSearchResults (searchText: String) -> Future<Response<[Place]>> {
        return networking(Endpoint.getSearchResults(searchText: searchText)).decode()
    }

    @objc func dismissVC() {
        if fromOnboarding {
            let rootVC = HomeViewController()
            let desiredViewController = CustomNavigationController(rootViewController: rootVC)

            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let window = appDelegate.window,
                let snapshot = window.snapshotView(afterScreenUpdates: true) {
                    desiredViewController.view.addSubview(snapshot)

                    appDelegate.window?.rootViewController = desiredViewController
                    userDefaults.setValue(true, forKey: Constants.UserDefaults.onboardingShown)

                    UIView.animate(withDuration: 0.5, animations: {
                        snapshot.layer.opacity = 0
                        snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
                    }, completion: { _ in
                        snapshot.removeFromSuperview()
                    })
                }
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsSection.items.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.placeIdentifier, for: indexPath) as! PlaceTableViewCell
        cell.place = resultsSection.items[indexPath.row]
        cell.layoutSubviews()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryView = UIActivityIndicatorView()
        tableView.deselectRow(at: indexPath, animated: true)
        let place = resultsSection.items[indexPath.row]

        if place.type == .busStop {
            SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.favorites, place: place, bottom: true)
            dismissVC()
        } else {
            // Fetch coordinates and store
            CoordinateVisitor.getCoordinates(for: place) { (latitude, longitude, error) in
                if error != nil {
                    print("Unable to get coordinates to save favorite.")
                    cell?.accessoryView = nil
                    let title = Constants.Alerts.PlacesFailure.title
                    let message = Constants.Alerts.PlacesFailure.message
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let done = UIAlertAction(title: Constants.Alerts.PlacesFailure.action, style: .default)
                    alertController.addAction(done)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    place.latitude = latitude
                    place.longitude = longitude
                    SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.favorites, place: place, bottom: true)
                    self.dismissVC()
                }
            }
        }

    }

}

// MARK: Empty Data Set
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

// MARK: Search
extension FavoritesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2,
                                     target: self,
                                     selector: #selector(getPlaces),
                                     userInfo: ["searchText": searchText],
                                     repeats: false)
    }

    /* Get Search Results */
    @objc func getPlaces(timer: Timer) {
        let searchText = (timer.userInfo as! [String: String])["searchText"]!
        if !searchText.isEmpty {
            getSearchResults(searchText: searchText).observe { [weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .value(let response):
                        if response.success {
                            self.resultsSection = Section(type: .searchResults, items: response.data)
                            self.tableView.contentOffset = .zero
                        } else {
                            print("[FavoritesTableViewController] success:", response.success)
                            self.resultsSection = Section(type: .searchResults, items: [Place]())
                        }
                    case .error(let error):
                        print("[FavoritesTableViewController] getSearchResults Error: \(error.localizedDescription)")
                        self.resultsSection = Section(type: .searchResults, items: [Place]())

                    }
                }
            }
        } else {
            resultsSection = Section(type: .searchResults, items: [Place]())
        }
    }

}
