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

enum RouteDetailItem {
    case direction (Direction)
    case busStop (LocationObject)

    func getDirection() -> Direction? {
        switch self {
        case .direction(let direction): return direction
        default: return nil
        }
    }

    func getBusStop() -> LocationObject? {
        switch self {
        case .busStop(let busStop): return busStop
        default: return nil
        }
    }
}

class RouteDetailDrawerViewController: UIViewController {

    let safeAreaCover = UIView()
    var summaryView: SummaryView!
    let tableView = UITableView()

    var directionsAndVisibleStops: [RouteDetailItem] = []
    var selectedDirection: Direction?

    /// Number of seconds to wait before auto-refreshing bus delay network call.
    private var busDelayNetworkRefreshRate: Double = 10
    private var busDelayNetworkTimer: Timer?
    private let chevronFlipDurationTime = 0.25
    /// Returns the currently expanded cell, if any
    var expandedCell: LargeDetailTableViewCell? {
        var firstExpandedCell: LargeDetailTableViewCell?
        (0..<tableView.numberOfRows(inSection: 0))
            .forEach { index in
                let indexPath = IndexPath(row: index, section: 0)
                if firstExpandedCell == nil,
                    let cell = tableView.cellForRow(at: indexPath) as? LargeDetailTableViewCell,
                    cell.isExpanded {
                    firstExpandedCell = cell
                }
        }
        return firstExpandedCell
    }
    private let networking: Networking = URLSession.shared.request
    private var route: Route!

    // MARK: Initalization
    init(route: Route) {
        super.init(nibName: nil, bundle: nil)
        self.route = route
        summaryView = SummaryView(route: route)
        self.directionsAndVisibleStops = route.directions.map({ RouteDetailItem.direction($0) })
    }

    required convenience init(coder aDecoder: NSCoder) {
        let route = aDecoder.decodeObject(forKey: "route") as! Route
        self.init(route: route)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.white
        
        setupSummaryView()
        setupTableView()
        setupSafeAreaCoverView()
        
        if let drawer = self.parent as? RouteDetailViewController {
            drawer.initialDrawerPosition = .partiallyRevealed
        }

        setupConstraints()
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

    private func setupSummaryView() {
        let summaryTapGesture = UITapGestureRecognizer(target: self, action: #selector(summaryTapped))
        summaryTapGesture.delegate = self
        summaryView.addGestureRecognizer(summaryTapGesture)
        view.addSubview(summaryView)
    }

    private func setupTableView() {
        tableView.bounces = false
        tableView.estimatedRowHeight = RouteDetailCellSize.smallHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(SmallDetailTableViewCell.self, forCellReuseIdentifier: Constants.Cells.smallDetailCellIdentifier)
        tableView.register(LargeDetailTableViewCell.self, forCellReuseIdentifier: Constants.Cells.largeDetailCellIdentifier)
        tableView.register(BusStopTableViewCell.self, forCellReuseIdentifier: Constants.Cells.busStopDetailCellIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: Constants.Footers.emptyFooterView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }

    /// Creates a temporary view to cover the drawer contents when collapsed. Hidden by default.
    private func setupSafeAreaCoverView() {
        safeAreaCover.backgroundColor = Colors.backgroundWash
        safeAreaCover.alpha = 0
        view.addSubview(safeAreaCover)
    }

    private func setupConstraints() {
        summaryView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(92) // TODO: Fix once summaryView is converted to snapkit
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(summaryView.snp.bottom)
        }

        safeAreaCover.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(summaryView.snp.bottom)
        }
    }

    /// Fetch delay information and update table view cells.
    @objc private func getDelays() {

        // First depart direction(s)
        guard let delayDirection = route.getFirstDepartRawDirection() else {
            return // Use rawDirection (preserves first stop metadata)
        }

        let directions = directionsAndVisibleStops.compactMap { $0.getDirection() }

        let firstDepartDirection = directions.first(where: { $0.type == .depart })!

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
                            directions.filter {
                                let isAfter = directions.firstIndex(of: firstDepartDirection)! < directions.firstIndex(of: $0)!
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
                            self.summaryView.updateTimes(for: self.route)
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
    func toggleCellExpansion(for cell: LargeDetailTableViewCell) {

        guard let indexPath = tableView.indexPath(for: cell),
            let direction = directionsAndVisibleStops[indexPath.row].getDirection() else { return }

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
        let busStops = direction.stops.map { return RouteDetailItem.busStop($0) }
        let busStopRange = (indexPath.row + 1)..<(indexPath.row + 1) + busStops.count
        let indexPathArray = busStopRange.map { return IndexPath(row: $0, section: 0) }

        tableView.beginUpdates()

        // Insert or remove bus stop data based on selection
        if cell.isExpanded {
            directionsAndVisibleStops.insert(contentsOf: busStops, at: indexPath.row + 1)
            tableView.insertRows(at: indexPathArray, with: .middle)
        } else {
            directionsAndVisibleStops.removeSubrange(busStopRange)
            tableView.deleteRows(at: indexPathArray, with: .middle)
        }

        tableView.endUpdates()
    }
}
