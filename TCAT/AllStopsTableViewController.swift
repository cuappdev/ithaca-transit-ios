//
//  AllStopsTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 11/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class AllStopsTableViewController: UITableViewController {

    var allStops: [BusStop]!
    var sectionIndexes: [String: [BusStop]]!
    var sortedKeys: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        sectionIndexes = sectionIndexesForBusStop()
        sortedKeys = Array(sectionIndexes.keys).sorted()

        title = "All Stops"
        tableView.sectionIndexColor = UIColor(white: 34.0 / 255.0, alpha: 1.0)
        tableView.register(BusStopCell.self, forCellReuseIdentifier: "BusStop")

        let titleAttributes: [String : Any] = [NSFontAttributeName : UIFont(name :".SFUIText", size: 18)!,
                                               NSForegroundColorAttributeName : UIColor.black]
        title = "All Stops"
        navigationController?.navigationBar.titleTextAttributes = titleAttributes

        navigationController?.navigationItem.titleView = nil

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sectionIndexesForBusStop() -> [String: [BusStop]] {
        var sectionIndexDictionary: [String: [BusStop]] = [:]
        var currentChar: Character = allStops[0].name.capitalized.first!
        var currBusStopArray: [BusStop] = []
        for busStop in allStops {
            if let firstChar = busStop.name.capitalized.first {
                if currentChar != firstChar {
                    sectionIndexDictionary["\(currentChar)"] = currBusStopArray
                    currBusStopArray = []
                    currentChar = firstChar
                } else {
                    currBusStopArray.append(busStop)
                }
            }
        }
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
        return (sectionIndexes[sortedKeys[section]]?.count)!
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

        insertRecentLocation(location: busStopSelected)
        optionsVC.searchTo = busStopSelected
        definesPresentationContext = false
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(optionsVC, animated: true)
    }

}
