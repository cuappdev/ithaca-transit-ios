//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Combine
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

    struct Section {
        let type: SectionType
        var items: [RouteDetailItem]
    }

    enum SectionType {
        case notification
        case routeDetail
    }

    enum RouteDetailItem {

        case busStop(LocationObject)
        case direction(Direction)
        case notificationType(NotificationType)

        func getDirection() -> Direction? {
            switch self {
            case .direction(let direction): return direction
            default: return nil
            }
        }

    }

    let safeAreaCover = UIView()
    var summaryView: SummaryView!
    let tableView = UITableView(frame: .zero, style: .grouped)

    private var cancellables = Set<AnyCancellable>()
    var currentPulleyPosition: PulleyPosition?
    var directionsAndVisibleStops: [RouteDetailItem] = []
    var expandedDirections: Set<Direction> = []
    var sections: [Section] = []
    var selectedDirection: Direction?

    /// Number of seconds to wait before auto-refreshing bus delay network call.
    private var busDelayNetworkRefreshRate: Double = 10
    private let chevronFlipDurationTime = 0.25
    private let route: Route

    // MARK: - Initalization
    init(route: Route) {
        self.route = route
        super.init(nibName: nil, bundle: nil)
        summaryView = SummaryView(route: route)
        directionsAndVisibleStops = route.directions.map({ RouteDetailItem.direction($0) })
    }

    required convenience init(coder aDecoder: NSCoder) {
        guard let route = aDecoder.decodeObject(forKey: "route") as? Route
            else { fatalError("init(coder:) has not been implemented") }
        self.init(route: route)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.white

        setupSummaryView()
        setupTableView()
        setupSafeAreaCoverView()
        setupSections()

        if let drawer = self.parent as? RouteDetailViewController {
            drawer.initialDrawerPosition = .partiallyRevealed
        }
        getDelays()
        setupConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
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
        tableView.register(
            SmallDetailTableViewCell.self,
            forCellReuseIdentifier: Constants.Cells.smallDetailCellIdentifier
        )
        tableView.register(
            LargeDetailTableViewCell.self,
            forCellReuseIdentifier: Constants.Cells.largeDetailCellIdentifier
        )
        tableView.register(
            BusStopTableViewCell.self,
            forCellReuseIdentifier: Constants.Cells.busStopDetailCellIdentifier
        )
        tableView.register(
            NotificationToggleTableViewCell.self,
            forCellReuseIdentifier: Constants.Cells.notificationToggleCellIdentifier
        )
        tableView.register(
            UITableViewHeaderFooterView.self,
            forHeaderFooterViewReuseIdentifier: Constants.Footers.emptyFooterView
        )
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: -34, left: 0.0, bottom: 34, right: 0.0)
        tableView.backgroundColor = Colors.white
        tableView.sectionHeaderHeight = 0
        view.addSubview(tableView)
    }

    /// Creates a temporary view to cover the drawer contents when collapsed. Hidden by default.
    private func setupSafeAreaCoverView() {
        safeAreaCover.backgroundColor = Colors.backgroundWash
        safeAreaCover.alpha = 0
        view.addSubview(safeAreaCover)
    }

    private func setupSections() {
        let notificationTypes = [
            RouteDetailItem.notificationType(.delay),
            RouteDetailItem.notificationType(.beforeBoarding)
        ]

        _ = Section(type: .notification, items: notificationTypes)
        let routeDetailSection = Section(type: .routeDetail, items: directionsAndVisibleStops)

        sections = [routeDetailSection]
        // TODO: Uncomment when notifications are implemented on backend
        //        if !route.isRawWalkingRoute() {
        //            sections.append(notificationSection)
        //        }
    }

    private func setupConstraints() {
        summaryView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
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
    private func getDelays() {

        // First depart direction(s)
        guard let delayDirection = route.getFirstDepartRawDirection() else {
            return // Use rawDirection (preserves first stop metadata)
        }

        let directions = directionsAndVisibleStops.compactMap { $0.getDirection() }
        guard let firstDepartDirection = directions.first(where: { $0.type == .depart }) else { return }

        // Reset delays for directions
        directions.forEach { $0.delay = nil }

        // Check if tripId and stopId are available
        if let tripId = delayDirection.tripIdentifiers?.first,
           let stopId = delayDirection.stops.first?.id {
            TransitService.shared.getDelay(tripID: tripId, stopID: stopId, refreshInterval: busDelayNetworkRefreshRate)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }

                    if case .failure(let error) = completion {
                        self.printClass(context: "\(#function) error", message: error.localizedDescription)
                        let payload = NetworkErrorPayload(
                            location: "\(self) Get Delay",
                            type: "\((error as NSError).domain)",
                            description: error.localizedDescription
                        )
                        TransitAnalytics.shared.log(payload)
                    }
                } receiveValue: { [weak self] delay in
                    guard let self = self else { return }

                    delayDirection.delay = delay
                    firstDepartDirection.delay = delay

                    directions.filter {
                        let isAfter = directions.firstIndex(of: firstDepartDirection)! < directions.firstIndex(of: $0)!
                        return isAfter && $0.type != .depart
                    }
                    .forEach { direction in
                        if let currentDelay = direction.delay {
                            direction.delay = currentDelay + (delay ?? 0)
                        } else {
                            direction.delay = delay
                        }
                    }

                    self.tableView.reloadData()
                    self.summaryView.updateTimes(for: self.route)
                }
                .store(in: &cancellables)
        }
    }

    func getFirstDirection() -> Direction? {
        return route.directions.first(where: { $0.type == .depart })
    }

    /// Toggle the cell expansion at the indexPath
    func toggleCellExpansion(for cell: LargeDetailTableViewCell) {

        guard let indexPath = tableView.indexPath(for: cell),
            let direction = sections[indexPath.section].items[indexPath.row].getDirection() else { return }

        // Prepare bus stop data to be inserted / deleted into Directions array
        let busStops = direction.stops.map { return RouteDetailItem.busStop($0) }
        let busStopRange = (indexPath.row + 1)..<((indexPath.row + 1) + busStops.count)
        let indexPathArray = busStopRange.map { return IndexPath(row: $0, section: 0) }

        tableView.beginUpdates()

        // Insert or remove bus stop data based on selection
        if expandedDirections.contains(direction) {
            expandedDirections.remove(direction)
            sections[indexPath.section].items.removeSubrange(busStopRange)
            tableView.deleteRows(at: indexPathArray, with: .middle)
        } else {
            expandedDirections.insert(direction)
            sections[indexPath.section].items.insert(contentsOf: busStops, at: indexPath.row + 1)
            tableView.insertRows(at: indexPathArray, with: .middle)
        }

        tableView.endUpdates()
    }

}
