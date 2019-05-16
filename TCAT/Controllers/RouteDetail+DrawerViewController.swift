//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import FutureNova
import Pulley
import SwiftyJSON
import UIKit

struct RouteDetailCellSize {
    static let indentedWidth: CGFloat = 140
    static let largeHeight: CGFloat = 80
    static let regularWidth: CGFloat = 120
    static let smallHeight: CGFloat = 60
}

class RouteDetailDrawerViewController: UIViewController {

    var safeAreaCover: UIView?
    var summaryView = SummaryView()
    var tableView: UITableView!

    var directions: [Direction] = []
    var justLoaded: Bool = true
    var ongoing: Bool = false
    var selectedDirection: Direction?
    var visible: Bool = false

    /// Number of seconds to wait before auto-refreshing bus delay network call.
    private var busDelayNetworkRefreshRate: Double = 10
    private var busDelayNetworkTimer: Timer?
    private let chevronFlipDurationTime = 0.25
    /// Dictionary that maps the original indexPath.row to the number of cells that specific row added
    private var expandedCellDict: [Int: Int] = [:]
    private let networking: Networking = URLSession.shared.request
    private var route: Route!

    // MARK: Initalization
    init(route: Route) {
        super.init(nibName: nil, bundle: nil)
        self.route = route
        self.directions = route.directions
    }

    func update(with route: Route) {
        self.route = route
        self.directions = route.directions
        tableView.reloadData()
    }

    required convenience init(coder aDecoder: NSCoder) {
        let route = aDecoder.decodeObject(forKey: "route") as! Route
        self.init(route: route)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDetailView()
        initializeCover()
        if let drawer = self.parent as? RouteDetailViewController {
            drawer.initialDrawerPosition = .partiallyRevealed
        }
        summaryView.setRoute()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Bus Delay Network Timer
        busDelayNetworkTimer?.invalidate()
        busDelayNetworkTimer = Timer.scheduledTimer(timeInterval: busDelayNetworkRefreshRate, target: self, selector: #selector(getDelays),
                                                    userInfo: nil, repeats: true)
        busDelayNetworkTimer?.fire()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        busDelayNetworkTimer?.invalidate()
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeCover()
    }

    // MARK: UIView Functions

    /** Create and configure detailView, summaryView, tableView */
    func initializeDetailView() {

        view.backgroundColor = Colors.white

        // Create summaryView

        summaryView.route = route
        let summaryTapGesture = UITapGestureRecognizer(target: self, action: #selector(summaryTapped))
        summaryTapGesture.delegate = self
        summaryView.addGestureRecognizer(summaryTapGesture)
        view.addSubview(summaryView)

        // Create Detail Table View
        tableView = UITableView()
        tableView.frame.origin = CGPoint(x: 0, y: summaryView.frame.height)
        tableView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - summaryView.frame.height)
        tableView.bounces = false
        tableView.estimatedRowHeight = RouteDetailCellSize.smallHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(SmallDetailTableViewCell.self, forCellReuseIdentifier: Constants.Cells.smallDetailCellIdentifier)
        tableView.register(LargeDetailTableViewCell.self, forCellReuseIdentifier: Constants.Cells.largeDetailCellIdentifier)
        tableView.register(BusStopTableViewCell.self, forCellReuseIdentifier: Constants.Cells.busStopDetailCellIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: Constants.Footers.emptyFooterView)
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)

    }

    /// Returns the currently expanded cell, if any
    var expandedCell: LargeDetailTableViewCell? {

        for index in 0..<tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? LargeDetailTableViewCell {
                if cell.isExpanded {
                    return cell
                }
            }

        }
        return nil
    }

    /// Creates a temporary view to cover the drawer contents when collapsed. Hidden by default.
    func initializeCover() {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.bottom ?? 34
            safeAreaCover = UIView(frame: CGRect(x: 0, y: summaryView.frame.height, width: UIScreen.main.bounds.width, height: bottom))
            safeAreaCover!.backgroundColor = Colors.backgroundWash
            safeAreaCover!.alpha = 0
            view.addSubview(safeAreaCover!)
        }
    }

    /// Remove cover view
    func removeCover() {
        safeAreaCover?.removeFromSuperview()
        safeAreaCover = nil
    }

    /// Fetch delay information and update table view cells.
    @objc func getDelays() {

        // First depart direction(s)
        guard let delayDirection = route.getFirstDepartRawDirection() else {
            return // Use rawDirection (preserves first stop metadata)
        }
        let firstDepartDirection = self.directions.first(where: { $0.type == .depart })!

        directions.forEach { $0.delay = nil }

        if let tripId = delayDirection.tripIdentifiers?.first,
            let stopId = delayDirection.stops.first?.id {

            getDelay(tripId: tripId, stopId: stopId).observe(with: { [weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .value(let response):
                        if response.success {

                            delayDirection.delay = response.data
                            firstDepartDirection.delay = response.data

                            // Update delay variable of other ensuing directions

                            self.directions.filter {
                                let isAfter = self.directions.firstIndex(of: firstDepartDirection)! < self.directions.firstIndex(of: $0)!
                                return isAfter && $0.type != .depart
                                }

                                .forEach { direction in
                                    if direction.delay != nil {
                                        direction.delay! += delayDirection.delay ?? 0
                                    } else {
                                        direction.delay = delayDirection.delay
                                    }
                            }

                            self.tableView.reloadData()
                            self.summaryView.setRoute()
                        } else {
                            print("getDelays success: false")
                        }
                    case .error(let error):
                        print("getDelays error: \(error.localizedDescription)")
                    }
                }
            })
        }
    }

    private func getDelay(tripId: String, stopId: String) -> Future<Response<Int?>> {
        return networking(Endpoint.getDelay(tripID: tripId, stopID: stopId)).decode()
    }

    /// Toggle the cell expansion at the indexPath
    func toggleCellExpansion(at indexPath: IndexPath?) {

        guard let indexPath = indexPath else { return }
        let expandedCellCount = expandedCellDict.reduce(0) { (result, arg1) -> Int in
            let (origRow, expandedCount) = arg1
            return indexPath.row > origRow ? result + expandedCount : result
        }

        let newIndexPath = IndexPath(row: indexPath.row + expandedCellCount, section: indexPath.section)

        guard let cell = tableView.cellForRow(at: newIndexPath) as? LargeDetailTableViewCell else { return }

        let direction = directions[newIndexPath.row]

        // Flip arrow
        cell.chevron.layer.removeAllAnimations()
        cell.isExpanded.toggle()

        let transitionOptionsOne: UIView.AnimationOptions = [.transitionFlipFromTop, .showHideTransitionViews]
        UIView.transition(with: cell.chevron, duration: chevronFlipDurationTime, options: transitionOptionsOne, animations: {
            cell.chevron.isHidden = true
        })

        cell.chevron.transform = cell.chevron.transform.rotated(by: CGFloat.pi)
        let transitionOptionsTwo: UIView.AnimationOptions = [.transitionFlipFromBottom, .showHideTransitionViews]
        UIView.transition(with: cell.chevron, duration: chevronFlipDurationTime, options: transitionOptionsTwo, animations: {
            cell.chevron.isHidden = false
        })

        // Prepare bus stop data to be inserted / deleted into Directions array
        let busStops = direction.stops.map { return Direction(name: $0.name, path: direction.path) }
        let busStopRange = (newIndexPath.row + 1)..<(newIndexPath.row + 1) + busStops.count
        let indexPathArray = busStopRange.map { return IndexPath(row: $0, section: 0) }

        tableView.beginUpdates()

        // Insert or remove bus stop data based on selection

        if cell.isExpanded {
            directions.insert(contentsOf: busStops, at: newIndexPath.row + 1)
            tableView.insertRows(at: indexPathArray, with: .middle)
            expandedCellDict[indexPath.row] = indexPathArray.count
        } else {
            directions.removeSubrange(busStopRange)
            tableView.deleteRows(at: indexPathArray, with: .middle)
            expandedCellDict.removeValue(forKey: indexPath.row)
        }

        tableView.endUpdates()

        busStops = []
        indexPathArray = []
    }
}
