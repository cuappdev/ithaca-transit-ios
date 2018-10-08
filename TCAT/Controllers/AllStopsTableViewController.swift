//
//  AllStopsTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 11/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol UnwindAllStopsTVCDelegate {
    func dismissSearchResultsVC(busStop: BusStop)
}

class AllStopsTableViewController: UITableViewController {

    var allStops: [BusStop]!
    var sectionIndexes: [String: [BusStop]]!
    var sortedKeys: [String]!
    var unwindAllStopsTVCDelegate: UnwindAllStopsTVCDelegate?
    var height: CGFloat?
    var currentChar: Character?
    var loadingIndicator: LoadingIndicator?

    override func viewWillLayoutSubviews() {
        if let y = navigationController?.navigationBar.frame.maxY {
            if height == nil {
                height = tableView.bounds.height
            }
            tableView.frame = CGRect(x: 0.0, y: y, width: view.bounds.width, height: height! - y)
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        sectionIndexes = sectionIndexesForBusStop()
        sortedKeys = sortedKeysForBusStops()

        title = "All Stops"
        tableView.sectionIndexColor = .primaryTextColor
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "BusStop")
        tableView.cellLayoutMarginsFollowReadableWidth = false

        if #available(iOS 11.0, *) {
            navigationItem.searchController = nil
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            navigationItem.titleView = nil
            automaticallyAdjustsScrollViewInsets = false
        }

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        // Set top of table view to align with scroll view
        tableView.contentOffset = .zero
    }

    // MARK: TableView DataSource

    /// Retrieves the section indexes for the bus stops
    func sectionIndexesForBusStop() -> [String: [BusStop]] {

        var sectionIndexDictionary: [String: [BusStop]] = [:]
        var currBusStopArray: [BusStop] = []

        currentChar = allStops.first?.name.capitalized.first

        var numberBusStops: [BusStop] = {
            guard let firstStop = allStops.first else { return [] }
            return [firstStop]
        }()

        if currentChar != nil {
            for busStop in allStops {
                if let firstChar = busStop.name.capitalized.first {
                    if currentChar != firstChar {
                        if !CharacterSet.decimalDigits.contains(currentChar!.unicodeScalars.first!) {
                            sectionIndexDictionary["\(currentChar!)"] = currBusStopArray
                            currBusStopArray = []
                        }
                        currentChar = firstChar
                        currBusStopArray.append(busStop)
                    } else {
                        if CharacterSet.decimalDigits.contains(currentChar!.unicodeScalars.first!) {
                            numberBusStops.append(busStop)
                        } else {
                            currBusStopArray.append(busStop)
                        }
                    }
                }
            }
        }

        if !allStops.isEmpty {
            // Adding "#" to section indexes for bus stops that start with a number
            sectionIndexDictionary["#"] = numberBusStops
        }

        return sectionIndexDictionary
    }

    /// Retrieves the keys from the sectionIndexDictionary
    func sortedKeysForBusStops() -> [String] {
        // Don't include key '#'
        sortedKeys = Array(sectionIndexes.keys)
            .sorted()
            .filter { $0 != "#" }

        if !allStops.isEmpty {
            // Adding "#" to keys for bus stops that start with a number
            sortedKeys.append("#")
        }

        return sortedKeys
    }

    func setUpTableOnRetry() {
        // Retry getting data from user defaults
        self.allStops = SearchTableViewManager.shared.getAllStops()
        // Set up table information
        self.sectionIndexes = self.sectionIndexesForBusStop()
        self.sortedKeys = self.sortedKeysForBusStops()

        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionIndexes.count
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sortedKeys
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedKeys[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionIndexes[sortedKeys[section]]?.count ?? 0
    }

    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let inset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = inset
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = inset
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusStop", for: indexPath) as! BusStopCell
        let section = sectionIndexes[sortedKeys[indexPath.section]]
        cell.textLabel?.text = section?[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sectionIndexes[sortedKeys[indexPath.section]]
        let optionsVC = RouteOptionsViewController()
        guard let busStopSelected = section?[indexPath.row] else {
            print("Could not find bus stop")
            return
        }
        SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.recentSearch, location: busStopSelected, limit: 8)
        optionsVC.searchTo = busStopSelected
        definesPresentationContext = false
        tableView.deselectRow(at: indexPath, animated: true)

        if let unwindDelegate = unwindAllStopsTVCDelegate {
            unwindDelegate.dismissSearchResultsVC(busStop: busStopSelected)
            navigationController?.popViewController(animated: true)
        } else {
            navigationController?.pushViewController(optionsVC, animated: true)
        }
    }

    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: DZNEmptyDataSet 
extension AllStopsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func setUpLoadingIndicator() {
        loadingIndicator = LoadingIndicator()
        if let loadingIndicator = loadingIndicator {
            view.addSubview(loadingIndicator)
            print("added loading indicator")
            loadingIndicator.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(40)
                make.height.equalTo(40)
            }
        }
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return loadingIndicator != nil ? nil : #imageLiteral(resourceName: "emptyPin")
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if loadingIndicator != nil {
            return nil
        }
        let title = "Couldn't Get Stops"
        let attrs = [NSAttributedString.Key.foregroundColor: UIColor.mediumGrayColor]
        return NSAttributedString(string: title, attributes: attrs)
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        if loadingIndicator != nil {
            return nil
        }
        let title = "Retry"
        let attrs = [NSAttributedString.Key.foregroundColor: UIColor.buttonColor]
        return NSAttributedString(string: title, attributes: attrs)
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTap didTapButton: UIButton) {
        setUpLoadingIndicator()
        tableView.reloadData()
        retryNetwork { () -> Void in
            self.loadingIndicator?.removeFromSuperview()
            self.loadingIndicator = nil
            self.setUpTableOnRetry()
        }
    }

    func retryNetwork(completion: @escaping () -> Void) {
        Network.getAllStops().perform(withSuccess: { stops in
            let allBusStops = stops.allStops
            if !allBusStops.isEmpty {
                // Only updating user defaults if retriving from network is successful
                let data = NSKeyedArchiver.archivedData(withRootObject: allBusStops)
                userDefaults.set(data, forKey: Constants.UserDefaults.allBusStops)
            }
            completion()
        }, failure: { error in
            print("AllStopsTableViewController.retryNetwork error:", error)
            completion()
        })
    }
}
