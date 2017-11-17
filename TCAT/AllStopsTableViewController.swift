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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = true
        sectionIndexes = sectionIndexesForBusStop()

        sortedKeys = Array(sectionIndexes.keys).sorted().filter({$0 != "#"})
        sortedKeys.append("#")

        title = "All Stops"
        tableView.sectionIndexColor = .primaryTextColor
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "BusStop")

        let titleAttributes: [NSAttributedStringKey: Any] = [.font : UIFont(name :".SFUIText", size: 18)!,
                                                             .foregroundColor : UIColor.black]
        title = "All Stops"
        navigationController?.navigationBar.titleTextAttributes = titleAttributes

        if #available(iOS 11.0, *) {
            navigationItem.searchController = nil
        } else {
            navigationItem.titleView = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sectionIndexesForBusStop() -> [String: [BusStop]] {
        var sectionIndexDictionary: [String: [BusStop]] = [:]
        var currentChar: Character = allStops[0].name.capitalized.first!
        var currBusStopArray: [BusStop] = []
        var numberBusStops: [BusStop] = []
        for busStop in allStops {
            if let firstChar = busStop.name.capitalized.first {
                if currentChar != firstChar {
                    if !CharacterSet.decimalDigits.contains(currentChar.unicodeScalars.first!) {
                        sectionIndexDictionary["\(currentChar)"] = currBusStopArray
                        currBusStopArray = []
                    }
                    currentChar = firstChar
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
        insertPlace(for: Key.UserDefaults.recentSearch, location: busStopSelected, limit: 8)
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

}
