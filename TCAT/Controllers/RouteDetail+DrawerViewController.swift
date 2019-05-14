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

    var summaryView = SummaryView()

    private var safeAreaCover: UIView?
    private var tableView: UITableView!

    /// Number of seconds to wait before auto-refreshing bus delay network call.
    private var busDelayNetworkRefreshRate: Double = 10
    private var busDelayNetworkTimer: Timer?
    private var directions: [Direction] = []
    private var justLoaded: Bool = true
    private let main = UIScreen.main.bounds
    private var ongoing: Bool = false
    private var visible: Bool = false

    private var selectedDirection: Direction?

    /// Dictionary that maps the original indexPath.row to the number of cells that specific row added
    var expandedCellDict: [Int: Int] = [:]

    private let chevronFlipDurationTime = 0.25

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
        tableView.frame.size = CGSize(width: main.width, height: main.height - summaryView.frame.height)
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
            safeAreaCover = UIView(frame: CGRect(x: 0, y: summaryView.frame.height, width: main.width, height: bottom))
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
            let (_, expandedCount) = arg1
            return result + expandedCount
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
        var busStops = direction.stops.map { stop in return Direction(name: stop.name, path: direction.path) }
        let busStopRange = (newIndexPath.row + 1)..<(newIndexPath.row + 1) + busStops.count
        var indexPathArray = busStopRange.map { i in return IndexPath(row: i, section: 0) }

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

// MARK: Gesture Recognizers and Interaction-Related Functions
extension RouteDetailDrawerViewController: UIGestureRecognizerDelegate {
    /** Animate detailTableView depending on context, centering map */
    @objc func summaryTapped(_ sender: UITapGestureRecognizer? = nil) {

        if let drawer = self.parent as? RouteDetailViewController {
            switch drawer.drawerPosition {
            case .collapsed, .partiallyRevealed:
                if selectedDirection != nil {
                    drawer.setDrawerPosition(position: .collapsed, animated: true)
                } else {
                    drawer.setDrawerPosition(position: .open, animated: true)
                }
            case .open:
                drawer.setDrawerPosition(position: .collapsed, animated: true)
            default: break
            }
        }
    }

}

extension RouteDetailDrawerViewController: LargeDetailTableViewDelegate {

    func collapseCells(on cell: UITableViewCell) {
        toggleCellExpansion(at: tableView.indexPath(for: cell))
    }

    func expandCells(on cell: UITableViewCell) {
        if justLoaded { summaryTapped() }

        toggleCellExpansion(at: tableView.indexPath(for: cell))

        tableView.layoutIfNeeded()
        tableView.layoutSubviews()
    }
}

extension RouteDetailDrawerViewController: PulleyDrawerViewControllerDelegate {
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return bottomSafeArea + summaryView.frame.height
    }

    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return main.height / 2
    }

    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {

        justLoaded = false
        // Center map on drawer change
        switch drawer.drawerPosition {
        case .collapsed, .partiallyRevealed:
            guard let contentViewController = drawer.primaryContentViewController as? RouteDetailContentViewController
                else { return }
            if let direction = selectedDirection {
                if direction.type == .depart || direction.type == .transfer {
                    contentViewController.centerMap(on: direction)
                } else {
                    contentViewController.centerMap(on: direction, overviewOfPath: true)
                }
                selectedDirection = nil
            } else {
                contentViewController.centerMapOnOverview(drawerPreviewing: drawer.drawerPosition == .partiallyRevealed)
            }
        default: break
        }
    }

    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {

        // Manage cover view hiding drawer when collapsed
        if distance - bottomSafeArea == summaryView.frame.height {
            safeAreaCover?.alpha = 1.0
            visible = true
        } else {
            if !ongoing && visible {
                UIView.animate(withDuration: 0.25, animations: {
                    self.safeAreaCover?.alpha = 0.0
                    self.visible = false
                }, completion: { _ in
                    self.ongoing = false
                })
            }
        }
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .partiallyRevealed, .open]
    }
}

extension RouteDetailDrawerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let direction = directions[indexPath.row]
        let isBusStopCell = direction.type == .arrive && direction.startLocation.latitude == 0.0
        let cellWidth: CGFloat = RouteDetailCellSize.regularWidth

        /// Formatting, including selectionStyle, and seperator line fixes
        func format(_ cell: UITableViewCell) -> UITableViewCell {
            cell.selectionStyle = .none
            if indexPath.row == directions.count - 1 {
                // Remove seperator at end of table
                cell.layoutMargins = UIEdgeInsets(top: 0, left: main.width, bottom: 0, right: 0)
            }
            return cell
        }

        if isBusStopCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.busStopDetailCellIdentifier) as! BusStopTableViewCell
            cell.setCell(direction.name)
            cell.layoutMargins = UIEdgeInsets(top: 0, left: cellWidth + 20, bottom: 0, right: 0)
            return format(cell)
        } else if direction.type == .walk || direction.type == .arrive {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.smallDetailCellIdentifier, for: indexPath) as! SmallDetailTableViewCell
            cell.setCell(direction,
                         firstStep: indexPath.row == 0,
                         lastStep: indexPath.row == directions.count - 1)
            cell.layoutMargins = UIEdgeInsets(top: 0, left: cellWidth, bottom: 0, right: 0)
            return format(cell)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.largeDetailCellIdentifier) as! LargeDetailTableViewCell
            cell.setCell(direction, indexPath: indexPath)
            cell.delegate = self
            cell.layoutMargins = UIEdgeInsets(top: 0, left: cellWidth, bottom: 0, right: 0)
            return format(cell)
        }

    }
}

extension RouteDetailDrawerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let direction = directions[indexPath.row]

        if direction.type == .depart || direction.type == .transfer {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.largeDetailCellIdentifier) as? LargeDetailTableViewCell
            cell?.setCell(direction, indexPath: indexPath)
            return cell?.height() ?? RouteDetailCellSize.largeHeight
        } else {
            return RouteDetailCellSize.smallHeight
        }

    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        // Empty Footer

        let emptyFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Footers.emptyFooterView) ??
            UITableViewHeaderFooterView(reuseIdentifier: Constants.Footers.emptyFooterView)

        let lastCellIndexPath = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
        var screenBottom = main.height
        if #available(iOS 11.0, *) {
            screenBottom -= view.safeAreaInsets.bottom
        }

        // Calculate height of space between last cell and the bottom of the screen, also accounting for summary
        var footerHeight = screenBottom - (tableView.cellForRow(at: lastCellIndexPath)?.frame.maxY ?? screenBottom) - summaryView.frame.height
        footerHeight = expandedCell != nil ? 0 : footerHeight

        emptyFooterView.frame.size = CGSize(width: view.frame.width, height: footerHeight)
        emptyFooterView.contentView.backgroundColor = Colors.white
        emptyFooterView.layoutIfNeeded()

        // Create Footer for No Data from Live Tracking Footer, if needed

        guard
            let drawer = self.parent as? RouteDetailViewController,
            let contentViewController = drawer.primaryContentViewController as? RouteDetailContentViewController
            else {
                return emptyFooterView
        }

        var message: String?

        if !contentViewController.noDataRouteList.isEmpty {
            if contentViewController.noDataRouteList.count > 1 {
                message = Constants.Banner.noLiveTrackingForRoutes
            } else {
                let routeNumber = contentViewController.noDataRouteList.first!
                message = Constants.Banner.noLiveTrackingForRoute + " " + "\(routeNumber)."
            }
        } else {
            message = nil
        }

        if let message = message {
            let phraseLabelFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Footers.phraseLabelFooterView)
                as? PhraseLabelFooterView ?? PhraseLabelFooterView(reuseIdentifier: Constants.Footers.phraseLabelFooterView)
            phraseLabelFooterView.setView(with: message)
            return phraseLabelFooterView
        }

        return emptyFooterView

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let direction = directions[indexPath.row]

        selectedDirection = direction

        if let drawer = self.parent as? RouteDetailViewController {
            drawer.setDrawerPosition(position: .collapsed, animated: true)
        }
    }
}
