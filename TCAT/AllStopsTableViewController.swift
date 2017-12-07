//
//  AllStopsTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 11/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

protocol UnwindAllStopsTVCDelegate {
    func dismissSearchResultsVC(busStop: BusStop)
}

class AllStopsTableViewController: UITableViewController {

    var allStops: [BusStop]!
    var sectionIndexes: [String: [BusStop]]!
    var sortedKeys: [String]!
    var unwindAllStopsTVCDelegate: UnwindAllStopsTVCDelegate?
    var navController: UINavigationController!
    var height: CGFloat?

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

        sortedKeys = Array(sectionIndexes.keys).sorted().filter({$0 != "#"})
        sortedKeys.append("#")

        title = "All Stops"
        tableView.sectionIndexColor = .primaryTextColor
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "BusStop")

        title = "All Stops"

        if #available(iOS 11.0, *) {
            navigationItem.searchController = nil
        } else {
            navigationItem.titleView = nil
        }

        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sectionIndexesForBusStop() -> [String: [BusStop]] {
        var sectionIndexDictionary: [String: [BusStop]] = [:]
        var currBusStopArray: [BusStop] = []

        var currentChar: Character = {
            guard let firstChar = allStops.first?.name.capitalized.first else { return Character("") }
            return firstChar
        }()

        var numberBusStops: [BusStop] = {
            guard let firstStop = allStops.first else { return [] }
            return [firstStop]
        }()

        for busStop in allStops {
            if let firstChar = busStop.name.capitalized.first {
                if currentChar != firstChar {
                    if !CharacterSet.decimalDigits.contains(currentChar.unicodeScalars.first!) {
                        sectionIndexDictionary["\(currentChar)"] = currBusStopArray
                        currBusStopArray = []
                    }
                    currentChar = firstChar
                    currBusStopArray.append(busStop)
                } else {
                    if CharacterSet.decimalDigits.contains(currentChar.unicodeScalars.first!) {
                        numberBusStops.append(busStop)
                    } else {
                    currBusStopArray.append(busStop)
                    }
                }
            }
        }
        sectionIndexDictionary["#"] = numberBusStops
        return sectionIndexDictionary
    }

    // MARK: - Table view data source

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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusStop", for: indexPath) as! BusStopCell
        let section = sectionIndexes[sortedKeys[indexPath.section]]
        cell.textLabel?.text = section?[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sectionIndexes[sortedKeys[indexPath.section]]
        let optionsVC = RouteOptionsViewController()
        guard let busStopSelected = section?[indexPath.row]
            else {
                print("Could not find bus stop")
                return
        }
        SearchTableViewManager.shared.insertPlace(for: Key.UserDefaults.recentSearch, location: busStopSelected, limit: 8)
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
