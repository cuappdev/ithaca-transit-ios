//
//  AllStopsTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 11/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import DZNEmptyDataSet
import FutureNova
import UIKit

protocol UnwindAllStopsTVCDelegate: class {
    func dismissSearchResultsVC(place: Place)
}

class AllStopsTableViewController: UITableViewController {

    private var allStops = [Place]()
    weak var unwindAllStopsTVCDelegate: UnwindAllStopsTVCDelegate?
    private var isLoading: Bool { return loadingIndicator != nil }
    private var loadingIndicator: LoadingIndicator?
    private let networking: Networking = URLSession.shared.request
    private var sectionIndexes = [String: [Place]]()
    private var sortedKeys = [String]()

    override func viewWillLayoutSubviews() {
        if let y = navigationController?.navigationBar.frame.maxY {
            tableView.frame = CGRect(x: 0.0, y: y, width: view.bounds.width, height: tableView.bounds.height - y)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.Titles.allStops
//        navigationItem.searchController = nil
        setupTableView()
        refreshAllStops()
    }

    private func setupTableView() {
        tableView.sectionIndexColor = Colors.primaryText
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: Constants.Cells.placeIdentifier)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        // Set top of table view to align with scroll view
        tableView.contentOffset = .zero
    }

    private func createSectionIndexesForBusStop() {
        var currentChar: Character?
        var sectionIndexDictionary: [String: [Place]] = [:]
        var currBusStopArray: [Place] = []

        currentChar = allStops.first?.name.capitalized.first

        var numberBusStops: [Place] = {
            if let firstStop = allStops.first {
                return [firstStop]
            } else {
                return []
            }
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

        // Adding "#" to section indexes for bus stops that start with a number
        if !allStops.isEmpty {
            sectionIndexDictionary["#"] = numberBusStops
        }

        sectionIndexes = sectionIndexDictionary
        sortBusStopKeys()
    }

    /// Retrieves the keys from the sectionIndexDictionary
    private func sortBusStopKeys() {
        // Don't include key '#'
        sortedKeys = Array(sectionIndexes.keys)
            .sorted()
            .filter { $0 != "#" }

        if !allStops.isEmpty {
            // Adding "#" to keys for bus stops that start with a number
            sortedKeys.append("#")
        }
    }

    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }

    private func setUpLoadingIndicator() {
        loadingIndicator = LoadingIndicator()
        if let loadingIndicator = loadingIndicator {
            view.addSubview(loadingIndicator)
            loadingIndicator.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(40)
            }
        }
    }

    private func getAllStops() -> Future<Response<[Place]>> {
        return networking(Endpoint.getAllStops()).decode()
    }

    /* Get all bus stops and store in userDefaults */
    private func refreshAllStops() {
        setUpLoadingIndicator()
        if let allBusStops = userDefaults.value(forKey: Constants.UserDefaults.allBusStops) as? Data,
            var busStopArray = try? decoder.decode([Place].self, from: allBusStops) {
            // Check if empty so that an empty array isn't returned
            if !busStopArray.isEmpty {
                // TODO: Move to backend
                // Creating "fake" bus stop to remove Google Places central Collegetown location choice
                let collegetownStop = Place(name: "Collegetown", latitude: 42.442558, longitude: -76.485336)
                busStopArray.append(collegetownStop)
                allStops = busStopArray
            }
            loadingIndicator?.removeFromSuperview()
            loadingIndicator = nil
            createSectionIndexesForBusStop()
            tableView.reloadData()
        } else {
            getAllStops().observe { [weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .value(var response):
                        if !response.data.isEmpty {
                            // Save bus stops in userDefaults
                            do {
                                let encodedObject = try JSONEncoder().encode(response.data)
                                userDefaults.set(encodedObject, forKey: Constants.UserDefaults.allBusStops)
                            } catch let error {
                                print(error)
                            }
                            let collegetownStop = Place(name: "Collegetown", latitude: 42.442558, longitude: -76.485336)
                            response.data.append(collegetownStop)
                            self.allStops = response.data
                        }
                    case .error(let error):
                        print("AllStopsTableViewController.retryNetwork error:", error)
                    }
                    self.loadingIndicator?.removeFromSuperview()
                    self.loadingIndicator = nil
                    self.createSectionIndexesForBusStop()
                    self.tableView.reloadData()
                }
            }
        }

    }
}

// MARK: DZNEmptyDataSetSource
extension AllStopsTableViewController: DZNEmptyDataSetSource {

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        // If loading indicator is being shown, don't display image
        return isLoading ? nil : #imageLiteral(resourceName: "serverDown")
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        // If loading indicator is being shown, don't display description
        if isLoading {
            return nil
        }
        let title = Constants.EmptyStateMessages.couldntGetStops
        return NSAttributedString(string: title, attributes: [.foregroundColor: Colors.metadataIcon])
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        // If loading indicator is being shown, don't display button
        if isLoading {
            return nil
        }
        let title = Constants.Buttons.retry
        return NSAttributedString(string: title, attributes: [.foregroundColor: Colors.tcatBlue])
    }
}

// MARK: DZNEmptyDataSetDelegate
extension AllStopsTableViewController: DZNEmptyDataSetDelegate {

    func emptyDataSet(_ scrollView: UIScrollView, didTap didTapButton: UIButton) {
        setUpLoadingIndicator()
        tableView.reloadData()
        refreshAllStops()
    }
}

// MARK: - TableView Delegate
extension AllStopsTableViewController {

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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.placeIdentifier) as! PlaceTableViewCell

        guard let section = sectionIndexes[sortedKeys[indexPath.section]] else { return cell }
        cell.configure(for: section[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sectionIndexes[sortedKeys[indexPath.section]]
        let optionsVC = RouteOptionsViewController()
        guard let place = section?[indexPath.row] else {
            print("Could not find bus stop")
            return
        }
        optionsVC.didSelectPlace(place: place)

        definesPresentationContext = false
        tableView.deselectRow(at: indexPath, animated: true)

        if let unwindDelegate = unwindAllStopsTVCDelegate {
            unwindDelegate.dismissSearchResultsVC(place: place)
            navigationController?.popViewController(animated: true)
        } else {
            navigationController?.pushViewController(optionsVC, animated: true)
        }
    }
}

// MARK: - Table view data source
extension AllStopsTableViewController {

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
}
